import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:preharness/core/constants/app_colors.dart';
import 'package:preharness/core/utils/global.dart';
import 'package:preharness/shared/ui/pattern_button.dart';

/// QRリーダー対応の検索カードウィジェット
class SearchCard extends StatefulWidget {
  final Function(String) onSearch;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSelectAll;

  const SearchCard({
    super.key,
    required this.onSearch,
    required this.controller,
    required this.focusNode,
    required this.onSelectAll,
  });

  @override
  State<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  // QRリーダーからの入力を保持する変数
  String _inputText = '';
  // ソフトキーボードモードが有効かどうかを管理する状態変数
  final bool _isKeyboardEnabled = false;
  // 検索が実行された直後かどうかを判断するフラグ
  bool _justSearched = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
    // 初期テキストをinputTextにも反映
    _inputText = widget.controller.text;
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  void _handleSearch() {
    // 現在のモードに応じてcontrollerにテキストをセット
    if (_isKeyboardEnabled) {
      _inputText = widget.controller.text;
    } else {
      widget.controller.text = _inputText;
    }

    if (widget.controller.text.isEmpty) return;
    widget.onSearch(widget.controller.text);

    // 検索が実行されたことを記録
    setState(() {
      _justSearched = true;
    });
  }

  // QRリーダーモードのウィジェット
  Widget _buildRawKeyboardReader() {
    return RawKeyboardListener(
      focusNode: widget.focusNode,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            _handleSearch();
            return;
          }
          if (event.logicalKey == LogicalKeyboardKey.backspace) {
            // Backspaceが押されたら、検索直後フラグはリセット
            _justSearched = false;
            if (_inputText.isNotEmpty) {
              setState(() {
                _inputText = _inputText.substring(0, _inputText.length - 1);
              });
            }
            return;
          }

          final char = event.character;
          if (char != null && char.isNotEmpty) {
            final code = char.codeUnits.first;
            if (code < 32 || code == 127) {
              return; // 制御文字は無視
            }

            setState(() {
              if (_justSearched) {
                // 検索直後の最初の入力であれば、テキストをクリアして置き換え
                _inputText = char;
              } else {
                // 既存のスキャンに追記
                _inputText += char;
              }
              // 文字が入力されたので、検索直後フラグはリセット
              _justSearched = false;
            });
          }
        }
      },
      child: GestureDetector(
        onTap: () {
          // タップ時にクリア処理を実行
          setState(() {
            _inputText = '';
            widget.controller.text = '';
          });
          widget.focusNode.requestFocus();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.getCardColor(context),
            border: Border.all(
              color: widget.focusNode.hasFocus
                  ? AppColors.getHighLightColor(context)
                  : AppColors.getLineColor(context),
              width: widget.focusNode.hasFocus ? 2.0 : 1.0,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _inputText.isEmpty ? 'エフをQRリーダーで読む' : _inputText,
            style: TextStyle(
              fontSize: 10,
              color: _inputText.isEmpty
                  ? Theme.of(context).hintColor
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }

  // ソフトキーボードモードのウィジェット
  Widget _buildTextField() {
    return TextField(
      style: const TextStyle(fontSize: 14),
      controller: widget.controller,
      focusNode: widget.focusNode,
      autocorrect: false,
      enableSuggestions: false,
      decoration: const InputDecoration(
        hintText: 'エフを手入力',
        isDense: true,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      inputFormatters: [HalfWidthTextInputFormatter()],
      onSubmitted: (_) => _handleSearch(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _isKeyboardEnabled
              ? _buildTextField()
              : _buildRawKeyboardReader(),
        ),
        const SizedBox(width: 10),
        PatternButton(
          label: "検索",
          fontSize: 14,
          width: 64,
          height: 32,
          onPressed: () {
            _handleSearch();
          },
        ),
      ],
    );
  }
}