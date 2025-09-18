import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import "package:preharness/constants/app_colors.dart";
import 'package:preharness/utils/shared_prefs_helper.dart';

int? _activeIndex;

class Measurement extends StatefulWidget {
  final List<Map<String, dynamic>>? chListData;
  final Function(String? recommendedHindDial)? onHindDialRecommendation;
  final Function(String? recommendedTopDial, String? recommendedBottomDial)?
  onFrontDialRecommendation;
  final String? currentHindDial;
  final String? currentTopDial;
  final String? currentBottomDial;
  final Function(bool)? onValidationComplete;
  final FocusNode? focusNode;
  final Map<String, String>? initialMeasurements;

  const Measurement({
    super.key,
    this.chListData,
    this.onHindDialRecommendation,
    this.onFrontDialRecommendation,
    this.currentHindDial,
    this.currentTopDial,
    this.currentBottomDial,
    this.onValidationComplete,
    this.focusNode,
    this.initialMeasurements,
  });

  @override
  State<Measurement> createState() => _StandardInfoCardState();
}

class _StandardInfoCardState extends State<Measurement> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  List<String> _statuses = []; // OK / NG 表示用
  bool _allMeasurementsValid = false;
  late final VoidCallback _focusListener;

  @override
  void initState() {
    super.initState();
    debugPrint('📏 [measurement] initState開始');

    // TextFieldの数に合わせてFocusNodeとControllerを作成
    _focusNodes = List.generate(4, (i) {
      final node = FocusNode();
      node.addListener(() {
        setState(() {
          _activeIndex = node.hasFocus
              ? i
              : (_activeIndex == i ? null : _activeIndex);
        });
      });
      return node;
    });
    _controllers = List.generate(4, (_) => TextEditingController());
    _statuses = List.generate(4, (_) => ""); // ← 初期は空

    // 外部フォーカスノードのリスナー設定
    if (widget.focusNode != null) {
      debugPrint('📏 [measurement] 外部フォーカスノード受信: ${widget.focusNode.hashCode}');
      _focusListener = () {
        debugPrint(
          '📏 [measurement] フォーカスリスナー呼び出し: hasFocus=${widget.focusNode!.hasFocus}, mounted=$mounted',
        );
        if (widget.focusNode!.hasFocus && mounted) {
          debugPrint('📏 測定セクションにフォーカス受信');
          // 外部フォーカスが当たったら最初のTextFieldにフォーカス
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              FocusScope.of(context).requestFocus(_focusNodes[0]);
              debugPrint('📏 最初のTextField にフォーカス移動');
            }
          });
        }
      };
      widget.focusNode!.addListener(_focusListener);
      debugPrint('📏 [measurement] フォーカスリスナー登録完了');
    } else {
      debugPrint('📏 [measurement] 外部フォーカスノードがnull');
    }

    // 初期値が提供されている場合、TextFieldに設定
    _setInitialValues();
  }

  void _setInitialValues() {
    debugPrint(
      '📋 [measurement] _setInitialValues呼び出し: ${widget.initialMeasurements}',
    );

    if (widget.initialMeasurements != null) {
      debugPrint('📋 [measurement] 初期値設定開始: ${widget.initialMeasurements}');

      final measurements = widget.initialMeasurements!;
      final labels = ["前足C/H", "後足C/H", "前足C/W", "後足C/W"];
      final keys = ["front_ch", "back_ch", "front_cw", "back_cw"];

      // 遅延して初期値を設定（ウィジェット構築完了後）
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (int i = 0; i < labels.length; i++) {
          final value = measurements[keys[i]];
          if (value != null) {
            // 初期値を3桁フォーマットで設定
            final double? parsed = double.tryParse(value);
            if (parsed != null) {
              final formatter = NumberFormat('0.000');
              _controllers[i].text = formatter.format(parsed);
            } else {
              _controllers[i].text = value;
            }
            _statuses[i] = "OK"; // 初期値がある場合はOK状態
            debugPrint(
              '📋 [measurement] ${labels[i]} = ${_controllers[i].text} (OK)',
            );
          }
        }

        // 全ての測定値がセットされた場合、バリデーションをチェック
        setState(() {
          _checkAllMeasurements();
        });

        debugPrint('📋 [measurement] 初期値設定完了');
      });
    } else {
      debugPrint('📋 [measurement] 初期値なし');
    }
  }

  void _checkAllMeasurements() {
    // 4つの測定値すべてがOKかどうかをチェック
    final allOK =
        _statuses.length == 4 && _statuses.every((status) => status == "OK");

    if (allOK != _allMeasurementsValid) {
      _allMeasurementsValid = allOK;

      // 全てOKの場合、全ての測定値を保存
      if (allOK) {
        _saveAllMeasurements();
      }

      // 親に通知
      if (widget.onValidationComplete != null) {
        debugPrint('📏 親への通知実行: onValidationComplete($allOK)');
        widget.onValidationComplete!(allOK);
      } else {
        debugPrint('📏 ⚠️ onValidationCompleteコールバックがnull');
      }

      debugPrint('📏 測定結果: ${allOK ? "全てOK" : "未完了またはNG"}');
    }
  }

  // 全ての測定値をSharedPreferencesに保存
  Future<void> _saveAllMeasurements() async {
    debugPrint('💾 全ての測定値を保存開始');

    // 測定値を保存
    final labels = ["前足C/H", "後足C/H", "前足C/W", "後足C/W"];

    for (int i = 0; i < labels.length; i++) {
      final text = _controllers[i].text;
      final value = double.tryParse(text);

      if (value != null) {
        await _saveMeasurementValue(labels[i], value);
      }
    }

    // block_terminals の値も一緒に保存
    await _saveBlockTerminals();

    debugPrint('💾 全ての測定値保存完了');
  }

  // block_terminals の値を measured_ として保存
  Future<void> _saveBlockTerminals() async {
    try {
      final blockTerminal0 = await SharedPrefsHelper.getString(
        'block_terminals_0',
      );
      final blockTerminal1 = await SharedPrefsHelper.getString(
        'block_terminals_1',
      );

      if (blockTerminal0 != null) {
        await SharedPrefsHelper.saveStringWithNotify(
          'measured_block_terminals_0',
          blockTerminal0,
        );
        debugPrint(
          '💾 block_terminals保存: measured_block_terminals_0 = $blockTerminal0',
        );
      }

      if (blockTerminal1 != null) {
        await SharedPrefsHelper.saveStringWithNotify(
          'measured_block_terminals_1',
          blockTerminal1,
        );
        debugPrint(
          '💾 block_terminals保存: measured_block_terminals_1 = $blockTerminal1',
        );
      }
    } catch (e) {
      debugPrint('❌ block_terminals保存エラー: $e');
    }
  }

  // 測定値をSharedPreferencesに保存
  Future<void> _saveMeasurementValue(String label, double value) async {
    String key;
    switch (label) {
      case "前足C/H":
        key = "measured_front_ch";
        break;
      case "後足C/H":
        key = "measured_back_ch";
        break;
      case "前足C/W":
        key = "measured_front_cw";
        break;
      case "後足C/W":
        key = "measured_back_cw";
        break;
      default:
        return; // 不明なラベルの場合は保存しない
    }

    await SharedPrefsHelper.saveStringWithNotify(key, value.toString());
    debugPrint('💾 測定値保存: $key = $value');
  }

  @override
  void dispose() {
    if (widget.focusNode != null) {
      widget.focusNode!.removeListener(_focusListener);
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var ctrl in _controllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  double _parseToDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  void _calculateRecommendedHindDial(
    double currentValue,
    double minValue,
    double maxValue,
  ) {
    // 目標値を計算 (min + max) / 2
    final targetValue = (minValue + maxValue) / 2;

    // 現在値と目標値の差分を計算
    final difference = currentValue - targetValue;

    // 1ダイヤル上げると0.05mm増加するので、必要な調整量を計算
    final dialAdjustment = (difference / 0.05).round();

    // 現在のダイヤル値を取得（デフォルトは中央値5）
    final currentDial = double.tryParse(widget.currentHindDial ?? '5') ?? 5.0;
    final recommendedDial = (currentDial - dialAdjustment).clamp(1.0, 10.0);

    widget.onHindDialRecommendation!(recommendedDial.toInt().toString());
  }

  void _calculateRecommendedFrontDials(
    double currentValue,
    double minValue,
    double maxValue,
  ) {
    // 計算の流れ:
    // 1. 目標値 = (規格下限 + 規格上限) / 2
    // 2. 差分 = 現在の計測値 - 目標値 (正なら目標より大きい、負なら目標より小さい)
    // 3. 必要調整量 = -差分 (計測値を目標に合わせるのに必要な変化量)
    // 4. 各ダイヤル組み合わせでの変化量を計算し、必要調整量に最も近いものを選択

    // 目標値を計算 (min + max) / 2
    final targetValue = (minValue + maxValue) / 2;

    // 現在値と目標値の差分を計算
    final difference = currentValue - targetValue;

    // 現在のダイヤル値を取得
    final currentTopDial = widget.currentTopDial ?? '0.5';
    final currentBottomDial =
        int.tryParse(widget.currentBottomDial ?? '1') ?? 1;

    // topDialの値から増加量をマッピング (ダイヤル設定による計測値への影響)
    final topDialValues = {
      '0.2/0.3': 0,
      '0.5': 0.1,
      '0.85': 0.2,
      '1.25': 0.33,
      '2.0': 0.48,
    };

    final topDialOptions = ['0.2/0.3', '0.5', '0.85', '1.25', '2.0'];
    final bottomDialOptions = [1, 2, 3, 4];

    // 現在のtopDial設定による計測値への影響
    final currentTopValue = topDialValues[currentTopDial] ?? 0.5;

    // bottomDialによる微調整 (1段階=0.02mm、bottomDial=1が基準値)
    // bottomDial=1→計測値+0mm, bottomDial=2→計測値+0.02mm, bottomDial=3→計測値+0.04mm, bottomDial=4→計測値+0.06mm

    // 目標への調整が必要な量 (正の値なら計測値を大きくする、負の値なら計測値を小さくする)
    final neededAdjustment = -difference; // 差分を埋めるのに必要な調整量

    // 最適なtopDialとbottomDialの組み合わせを探す
    String? bestTopDial;
    int bestBottomDial = 1;
    double minError = double.infinity;

    // 全ての組み合わせを試して最適解を探す
    for (String topOption in topDialOptions) {
      final topValue = topDialValues[topOption]!;
      final topChange = topValue - currentTopValue; // topDialを変更した場合の計測値変化量

      for (int bottomOption in bottomDialOptions) {
        final bottomChange =
            (bottomOption - currentBottomDial) *
            0.08; // bottomDialを変更した場合の計測値変化量
        final totalChange = topChange + bottomChange; // 両方を変更した場合の総変化量
        final error = (totalChange - neededAdjustment).abs(); // 必要調整量との誤差

        // より小さい誤差の組み合わせを採用
        if (error < minError) {
          minError = error;
          bestTopDial = topOption;
          bestBottomDial = bottomOption;
        }
      }
    }

    if (bestTopDial != null) {
      widget.onFrontDialRecommendation?.call(
        bestTopDial,
        bestBottomDial.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.black : AppColors.paperWhite;
    final labelColor = isDark ? Colors.white70 : Colors.black87;
    final fieldBgColor = isDark ? AppColors.paperBlack : Colors.white;
    final fieldTextColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.grey[400]! : Colors.grey;

    final highLightColor = AppColors.getHighLightColor(context); // ← 1回だけ取得

    // ラベルと規格値のリスト
    final rows = (widget.chListData != null && widget.chListData!.isNotEmpty)
        ? [
            {
              "label": "前足C/H",
              "min": _parseToDouble(widget.chListData![0]['chff']),
              "max": _parseToDouble(widget.chListData![0]['chft']),
            },
            {
              "label": "後足C/H",
              "min": _parseToDouble(widget.chListData![0]['chrf']),
              "max": _parseToDouble(widget.chListData![0]['chrt']),
            },
            {
              "label": "前足C/W",
              "min": _parseToDouble(widget.chListData![0]['cwff']),
              "max": _parseToDouble(widget.chListData![0]['cwft']),
            },
            {
              "label": "後足C/W",
              "min": _parseToDouble(widget.chListData![0]['cw1rf']),
              "max": _parseToDouble(widget.chListData![0]['cw1rt']),
            },
          ]
        : [
            {"label": "前足C/H", "min": 0.900, "max": 1.000},
            {"label": "後足C/H", "min": 2.200, "max": 2.300},
            {"label": "前足C/W", "min": 1.350, "max": 1.550},
            {"label": "後足C/W", "min": 2.150, "max": 2.350},
          ];

    return SizedBox(
      width: 180,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          border: Border.all(color: AppColors.getLineColor(context), width: .5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Card(
          color: cardColor,
          elevation: 3,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 0),
                for (int i = 0; i < rows.length; i++)
                  _buildRow(
                    rows[i]["label"] as String,
                    rows[i]["min"] as double,
                    rows[i]["max"] as double,
                    i,
                    _focusNodes[i],
                    _controllers[i],
                    isDark,
                    fieldBgColor,
                    fieldTextColor,
                    labelColor,
                    hintColor,
                    _activeIndex == i ? highLightColor : labelColor,
                    _statuses[i], // ← 追加
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "※単位は全てmm",
                    style: TextStyle(fontSize: 11, color: labelColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 小数点3桁フォーマットを適用（シンプル版）
  void _formatToThreeDecimals(TextEditingController controller) {
    if (controller.text.isNotEmpty) {
      final double? parsed = double.tryParse(controller.text);
      if (parsed != null) {
        final formatter = NumberFormat('0.000');
        final formatted = formatter.format(parsed);
        controller.text = formatted;
      }
    }
  }

  Widget _buildRow(
    String label,
    double minValue,
    double maxValue,
    int index,
    FocusNode focusNode,
    TextEditingController controller,
    bool isDark,
    Color fieldBgColor,
    Color fieldTextColor,
    Color labelColor,
    Color hintColor,
    Color activeIndex, // ← これが12個目
    String status, // ← 追加
  ) {
    final highLightColor = AppColors.getHighLightColor(context); // ← 1回だけ取得
    final baseColor = AppColors.getLineColor(context); // ← 1回だけ取得

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Positioned(
                right: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 30, child: Text("")),
                    SizedBox(
                      width: 109,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "${minValue.toStringAsFixed(3)}～${maxValue.toStringAsFixed(3)}",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: fieldTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none, // はみ出しを許可
                    children: [
                      SizedBox(
                        width: 150,
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          showCursor: true,
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.none,
                          onEditingComplete: () {
                            // フォーカスが外れた時に3桁フォーマットを適用
                            _formatToThreeDecimals(controller);
                          },
                          onTap: () {
                            // テキストフィールドタップ時に全選択
                            controller.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: controller.text.length,
                            );
                          },
                          style: TextStyle(color: fieldTextColor), // styleを元に戻す
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: fieldBgColor,
                            contentPadding: const EdgeInsets.symmetric(
                              // paddingを元に戻す
                              horizontal: 8,
                              vertical: 8,
                            ),
                            hintText: '',
                            hintStyle: TextStyle(
                              color: hintColor,
                              fontSize: 12,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: baseColor,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: highLightColor,
                                width: 2.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: baseColor,
                                width: 1.0,
                              ),
                            ),
                          ),
                          onSubmitted: (_) async {
                            // まず3桁フォーマットを適用
                            _formatToThreeDecimals(controller);

                            debugPrint(
                              '📏 [measurement] onSubmitted: label=$label, text=${controller.text}',
                            );
                            final input = double.tryParse(controller.text);
                            debugPrint(
                              '📏 [measurement] parsed value: $input, range: $minValue-$maxValue',
                            );

                            if (input != null &&
                                input >= minValue &&
                                input <= maxValue) {
                              debugPrint(
                                '📏 [measurement] OK判定: $label = $input',
                              );
                              setState(() {
                                _statuses[index] = "OK";
                              });

                              // 全ての測定値チェック後、全てOKなら保存
                              _checkAllMeasurements();

                              // OK判定の場合は推奨値をクリア
                              if (label == "後足C/H" &&
                                  widget.onHindDialRecommendation != null) {
                                widget.onHindDialRecommendation!(null);
                              }
                              if (label == "前足C/H" &&
                                  widget.onFrontDialRecommendation != null) {
                                widget.onFrontDialRecommendation!(null, null);
                              }

                              if (index + 1 < _focusNodes.length) {
                                FocusScope.of(
                                  context,
                                ).requestFocus(_focusNodes[index + 1]);
                              } else {
                                focusNode.unfocus();
                              }
                            } else {
                              setState(() {
                                _statuses[index] = "NG";
                                _checkAllMeasurements();
                              });

                              // 後足C/Hの場合は推奨ダイヤル値を計算
                              if (label == "後足C/H" &&
                                  input != null &&
                                  widget.onHindDialRecommendation != null) {
                                _calculateRecommendedHindDial(
                                  input,
                                  minValue,
                                  maxValue,
                                );
                              }

                              // 前足C/Hの場合は推奨ダイヤル値を計算
                              if (label == "前足C/H" &&
                                  input != null &&
                                  widget.onFrontDialRecommendation != null) {
                                _calculateRecommendedFrontDials(
                                  input,
                                  minValue,
                                  maxValue,
                                );
                              }

                              // フォーカスを当ててテキストを選択状態にする
                              focusNode.requestFocus();
                              controller.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: controller.text.length,
                              );
                            }
                          },
                        ),
                      ),
                      // フィールドタイトル
                      SizedBox(
                        width: 50,
                        height: 40,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 2,
                              left: 4,
                              child: Text(
                                label,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: activeIndex,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // OK/NG
                      if (status.isNotEmpty)
                        Positioned(
                          right: 1, // 右側に30はみ出す
                          top: -24,
                          bottom: 0,
                          child: Center(
                            child: Icon(
                              status == "OK"
                                  ? Icons.check_circle
                                  : Icons.cancel, // アイコンを条件で分ける
                              size: 15,
                              color: status == "OK"
                                  ? AppColors.getLineSubColor(context)
                                  : AppColors.getErrorColor(context),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
