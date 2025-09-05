import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:preharness/constants/app_colors.dart';

class SubItem {
  final String label;
  final String value;
  final double? valueFont;
  final int? flex;
  final String? prefsKey; // SharedPreferences保存用キー（nullの場合は表示のみ）
  final Function(String)? onInputComplete; // 入力完了時のコールバック

  SubItem({
    required this.label,
    required this.value,
    this.valueFont = 24,
    this.flex = 1,
    this.prefsKey,
    this.onInputComplete,
  });
}

enum ValidationState { none, valid, error }

class CustomInputCard extends StatefulWidget {
  final String title; // カード上部に浮いて表示されるタイトル（例: 'マイクロメーター'）
  final List<SubItem> subItems; // カード内に表示するラベル+値のリスト（各SubItemで入力機能を制御）
  final ValidationState? externalValidation; // 外部からの検証状態
  final bool autoFocus; // 自動フォーカス
  final FocusNode? externalFocusNode; // 外部フォーカスノード

  const CustomInputCard({
    super.key,
    required this.title,
    required this.subItems,
    this.externalValidation,
    this.autoFocus = false,
    this.externalFocusNode,
  });

  @override
  State<CustomInputCard> createState() => CustomInputCardState();
}

class CustomInputCardState extends State<CustomInputCard> {
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _inputTexts = {};
  final Map<String, bool> _showTextFields = {};
  final Map<String, Timer?> _selectionTimers = {};
  final Map<String, String> _savedValues = {};
  bool _justSearched = false;
  final FocusNode _keyboardListenerFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    for (var subItem in widget.subItems) {
      if (subItem.prefsKey != null) {
        final key = subItem.prefsKey!;
        _focusNodes[key] = widget.externalFocusNode ?? FocusNode();
        _controllers[key] = TextEditingController();
        _inputTexts[key] = '';
        _showTextFields[key] = false;
        _savedValues[key] = subItem.value;

        _loadSavedValue(key);
        _focusNodes[key]!.addListener(() {
          setState(() {
            if (!_focusNodes[key]!.hasFocus) {
              _showTextFields[key] = false;
            }
          });
        });
      }
    }

    // 自動フォーカス処理
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        triggerExternalFocus();
      });
    }
  }

  void _triggerFocus() {
    final inputSubItem = widget.subItems.firstWhere(
      (item) => item.prefsKey != null,
      orElse: () => widget.subItems.first,
    );
    if (inputSubItem.prefsKey != null) {
      final key = inputSubItem.prefsKey!;
      setState(() {
        _showTextFields[key] = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_focusNodes[key]!);
        if (_controllers[key]!.text.isNotEmpty) {
          _controllers[key]!.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[key]!.text.length,
          );
        }
      });
    }
  }

  // 外部からタップ処理をトリガー
  void triggerTap() {
    // 入力可能なSubItemがあるかチェック
    final hasAnyInput = widget.subItems.any((item) => item.prefsKey != null);
    
    if (hasAnyInput) {
      // 入力可能なSubItemの最初のprefsKeyでフィールドを表示
      final inputSubItem = widget.subItems.firstWhere(
        (item) => item.prefsKey != null,
      );
      final key = inputSubItem.prefsKey!;
      setState(() {
        _showTextFields[key] = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_focusNodes[key]!);
        if (_controllers[key]!.text.isNotEmpty) {
          _controllers[key]!.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[key]!.text.length,
          );
        }
      });
    }
  }

  // 外部からのフォーカス制御用メソッド
  void triggerExternalFocus() {
    if (widget.externalFocusNode != null) {
      // 外部フォーカスノードが指定されている場合、そのキーを探す
      String? targetKey;
      for (var subItem in widget.subItems) {
        if (subItem.prefsKey != null && _focusNodes[subItem.prefsKey!] == widget.externalFocusNode) {
          targetKey = subItem.prefsKey!;
          break;
        }
      }
      
      if (targetKey != null) {
        setState(() {
          _showTextFields[targetKey!] = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(_focusNodes[targetKey]!);
          if (_controllers[targetKey]!.text.isNotEmpty) {
            _controllers[targetKey]!.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _controllers[targetKey]!.text.length,
            );
          }
        });
      }
    } else {
      // 通常のautoFocus処理
      _triggerFocus();
    }
  }

  @override
  void dispose() {
    for (var timer in _selectionTimers.values) {
      timer?.cancel();
    }
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _keyboardListenerFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSavedValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final savedValue = prefs.getString(key);
    if (savedValue != null) {
      setState(() {
        _savedValues[key] = savedValue;
      });
    }
  }

  Future<void> _saveSavedValue(
    String key,
    String value,
    SubItem subItem,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    setState(() {
      _savedValues[key] = value;
    });
    subItem.onInputComplete?.call(value);
  }

  void _startSelectionTimer(String key, SubItem subItem) {
    _selectionTimers[key]?.cancel();
    _selectionTimers[key] = Timer(const Duration(milliseconds: 500), () {
      if (_controllers[key]!.text.isNotEmpty && _focusNodes[key]!.hasFocus) {
        _controllers[key]!.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controllers[key]!.text.length,
        );
        _saveSavedValue(key, _controllers[key]!.text, subItem);
      }
    });
  }

  void _handleKeyboardInput(KeyEvent event) {
    // アクティブなフォーカスノードとSubItemを検索
    String? activeKey;
    SubItem? activeSubItem;

    for (var subItem in widget.subItems) {
      if (subItem.prefsKey != null &&
          _focusNodes[subItem.prefsKey!]!.hasFocus) {
        activeKey = subItem.prefsKey!;
        activeSubItem = subItem;
        break;
      }
    }

    if (activeKey == null || activeSubItem == null) return;

    // activeKeyがnullでないことが確定したので、ローカル変数として使用
    final String key = activeKey;

    if (event is KeyDownEvent) {
      // 終端文字検知時は即座に保存
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.tab ||
          event.character == '\n' ||
          event.character == '\r') {
        // タイマーをキャンセルして即座に保存
        _selectionTimers[key]?.cancel();
        if (_controllers[key]!.text.isNotEmpty) {
          _saveSavedValue(key, _controllers[key]!.text, activeSubItem);
        }
        _focusNodes[key]!.unfocus();
        return;
      }
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        _justSearched = false;
        if ((_inputTexts[key] ?? '').isNotEmpty) {
          setState(() {
            final currentText = _inputTexts[key] ?? '';
            _inputTexts[key] = currentText.substring(0, currentText.length - 1);
            _controllers[key]!.text = _inputTexts[key]!;
          });
        }
        return;
      }
      final char = event.character;
      if (char != null && char.isNotEmpty) {
        if (_justSearched) {
          setState(() {
            _inputTexts[key] = char;
            _controllers[key]!.text = char;
            _justSearched = false;
          });
          _startSelectionTimer(key, activeSubItem);
        } else {
          // 選択状態からの入力を処理
          if (_controllers[key]!.selection.baseOffset !=
              _controllers[key]!.selection.extentOffset) {
            // テキストが選択されている場合、置き換える
            setState(() {
              _inputTexts[key] = char;
              _controllers[key]!.text = char;
            });
          } else {
            // 通常の追加入力
            setState(() {
              final currentText = _inputTexts[key] ?? '';
              _inputTexts[key] = currentText + char;
              _controllers[key]!.text = _inputTexts[key]!;
            });
          }
          // 入力継続中はタイマーをリセット
          _startSelectionTimer(key, activeSubItem);
        }
      }
    }
  }

  Widget _buildLabelValue(SubItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(item.label, style: TextStyle(fontSize: 11, height: 1.0)),
        Text(
          item.value,
          style: TextStyle(fontSize: item.valueFont, height: 1.0),
        ),
      ],
    );
  }

  IconData _getValidationIcon() {
    if (widget.externalValidation != null) {
      switch (widget.externalValidation!) {
        case ValidationState.valid:
          return Icons.check_circle;
        case ValidationState.error:
          return Icons.cancel;
        case ValidationState.none:
          return Icons.help_outline;
      }
    }
    // デフォルトの内部バリデーション
    return _savedValues.values.any((value) => value.isNotEmpty)
        ? Icons.check_circle
        : Icons.cancel;
  }

  Color _getValidationColor() {
    if (widget.externalValidation != null) {
      switch (widget.externalValidation!) {
        case ValidationState.valid:
          return AppColors.getLineSubColor(context);
        case ValidationState.error:
          return AppColors.getErrorColor(context);
        case ValidationState.none:
          return AppColors.getLineColor(context);
      }
    }
    // デフォルトの内部バリデーション
    return _savedValues.values.any((value) => value.isNotEmpty)
        ? AppColors.getLineSubColor(context)
        : AppColors.getErrorColor(context);
  }

  Widget _buildSubItemsRow() {
    return Row(
      children: [
        for (int i = 0; i < widget.subItems.length; i++) ...[
          if (i > 0) SizedBox(width: 8),
          Expanded(
            flex: widget.subItems[i].flex ?? 1,
            child: _buildLabelValue(widget.subItems[i]),
          ),
        ],
        // 入力可能なSubItemがある場合はアイコンを表示
        if (widget.subItems.any((item) => item.prefsKey != null)) ...[
          SizedBox(width: 3),
          Icon(
            _getValidationIcon(),
            color: _getValidationColor(),
            size: 20,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 入力可能なSubItemがあるかチェック
    final hasAnyInput = widget.subItems.any((item) => item.prefsKey != null);

    return KeyboardListener(
      focusNode: _keyboardListenerFocusNode,
      onKeyEvent: _handleKeyboardInput,
      child: GestureDetector(
        onTap: hasAnyInput
            ? () {
                // 入力可能なSubItemの最初のprefsKeyでフィールドを表示
                final inputSubItem = widget.subItems.firstWhere(
                  (item) => item.prefsKey != null,
                );
                final key = inputSubItem.prefsKey!;
                setState(() {
                  _showTextFields[key] = true;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  FocusScope.of(context).requestFocus(_focusNodes[key]!);
                  if (_controllers[key]!.text.isNotEmpty) {
                    _controllers[key]!.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _controllers[key]!.text.length,
                    );
                  }
                });
              }
            : null,
        child: Stack(
          children: [
            Card(
              color: AppColors.getCardColor(context),
              elevation: 3,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.getLineColor(context),
                    width: .5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: hasAnyInput
                      ? const EdgeInsets.fromLTRB(8, 12, 8, 0)
                      : const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: hasAnyInput ? 2 : 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 入力フィールドを表示（入力可能なSubItemがある場合のみ）
                            for (var subItem in widget.subItems)
                              if (subItem.prefsKey != null) ...[
                                Visibility(
                                  visible:
                                      _showTextFields[subItem.prefsKey!] ??
                                      false,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              focusNode:
                                                  _focusNodes[subItem
                                                      .prefsKey!],
                                              controller:
                                                  _controllers[subItem
                                                      .prefsKey!],
                                              showCursor: true,
                                              textAlign: TextAlign.right,
                                              readOnly: true,
                                              keyboardType: TextInputType.none,
                                              onTap: () {
                                                _controllers[subItem.prefsKey!]!
                                                    .selection = TextSelection(
                                                  baseOffset: 0,
                                                  extentOffset:
                                                      _controllers[subItem
                                                              .prefsKey!]!
                                                          .text
                                                          .length,
                                                );
                                              },
                                              style: TextStyle(
                                                color: AppColors.getLineColor(
                                                  context,
                                                ),
                                                fontSize: 14,
                                              ),
                                              decoration: InputDecoration(
                                                isDense: true,
                                                filled: true,
                                                fillColor:
                                                    AppColors.getCardColor(
                                                      context,
                                                    ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 8,
                                                    ),
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color:
                                                        AppColors.getLineColor(
                                                          context,
                                                        ),
                                                    width: 1.0,
                                                  ),
                                                ),
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color:
                                                        AppColors.getHighLightColor(
                                                          context,
                                                        ),
                                                    width: 2.0,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            AppColors.getLineColor(
                                                              context,
                                                            ),
                                                        width: 1.0,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ],
                            _buildSubItemsRow(),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // タイトルを浮かせて表示
            Positioned(
              top: -4,
              left: 12,
              height: 18,
              child: Container(
                color: AppColors.getCardColor(context),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getLineColor(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
