import 'package:flutter/material.dart';
import "package:preharness/constants/app_colors.dart";

int? _activeIndex;

class Measurement extends StatefulWidget {
  final List<Map<String, dynamic>>? chListData;
  final Function(String? recommendedHindDial)? onHindDialRecommendation;
  final Function(String? recommendedTopDial, String? recommendedBottomDial)?
  onFrontDialRecommendation;
  final String? currentHindDial;
  final String? currentTopDial;
  final String? currentBottomDial;

  const Measurement({
    super.key,
    this.chListData,
    this.onHindDialRecommendation,
    this.onFrontDialRecommendation,
    this.currentHindDial,
    this.currentTopDial,
    this.currentBottomDial,
  });

  @override
  State<Measurement> createState() => _StandardInfoCardState();
}

class _StandardInfoCardState extends State<Measurement> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  List<String> _statuses = []; // OK / NG 表示用
  @override
  void initState() {
    super.initState();

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
    // 最初のTextFieldにフォーカスを当てる
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  @override
  void dispose() {
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
      '0.2/0.3': 0, // topDial=0.2/0.3の場合、計測値が0.2mm増加
      '0.5': 0.05, // topDial=0.5の場合、計測値が0.5mm増加
      '0.85': 0.1, // topDial=0.85の場合、計測値が0.85mm増加
      '1.25': 0.15, // topDial=1.25の場合、計測値が1.25mm増加
      '2.0': 0.2, // topDial=2.0の場合、計測値が2.0mm増加
    };

    final topDialOptions = ['0.2/0.3', '0.5', '0.85', '1.25', '2.0'];
    final bottomDialOptions = [1, 2, 3, 4];

    // 現在のtopDial設定による計測値への影響
    final currentTopValue = topDialValues[currentTopDial] ?? 0.5;

    // bottomDialによる微調整 (1段階=0.02mm、bottomDial=1が基準値)
    // bottomDial=1→計測値+0mm, bottomDial=2→計測値+0.02mm, bottomDial=3→計測値+0.04mm, bottomDial=4→計測値+0.06mm
    final currentBottomAdjustment = (currentBottomDial - 1) * 0.02;

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
            0.02; // bottomDialを変更した場合の計測値変化量
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

    return Center(
      child: SizedBox(
        width: 220,
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            border: Border.all(color: Colors.white, width: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Card(
            color: cardColor,
            elevation: 4,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                  Text(
                    "※単位は全てmm",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: labelColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 30, child: Text("")),
                  SizedBox(
                    width: 120,
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

              const SizedBox(height: 0),
              Row(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        width: 150,
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          // readOnly: true,
                          showCursor: true,
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.none,
                          style: TextStyle(color: fieldTextColor),
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: fieldBgColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            hintText: '',
                            hintStyle: TextStyle(
                              color: hintColor,
                              fontSize: 12,
                            ),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: highLightColor,
                                width: 2.0,
                              ),
                            ),
                          ),
                          onSubmitted: (_) {
                            final input = double.tryParse(controller.text);
                            if (input != null &&
                                input >= minValue &&
                                input <= maxValue) {
                              setState(() {
                                _statuses[index] = "OK";
                              });
                              
                              // OK判定の場合は推奨値をクリア
                              if (label == "後足C/H" && widget.onHindDialRecommendation != null) {
                                widget.onHindDialRecommendation!(null);
                              }
                              if (label == "前足C/H" && widget.onFrontDialRecommendation != null) {
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
                    ],
                  ),
                  SizedBox(width: 4),
                  SizedBox(
                    width: 20,
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: status == "OK"
                            ? AppColors.neonGreen
                            : status == "NG"
                            ? Colors.red
                            : Colors.transparent,
                      ),
                    ),
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
