import 'package:flutter/material.dart';
import "package:preharness/constants/app_colors.dart";

int? _activeIndex;

class Measurement extends StatefulWidget {
  final List<Map<String, dynamic>>? chListData;
  const Measurement({super.key, this.chListData});

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
