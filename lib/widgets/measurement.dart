import 'package:flutter/material.dart';
import "package:preharness/constants/app_colors.dart";

int? _activeIndex;

class Measurement extends StatefulWidget {
  const Measurement({super.key});

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
    final rows = [
      {"label": "前足C/H", "min": 0.900, "max": 1.000},
      {"label": "後足C/H", "min": 2.200, "max": 2.300},
      {"label": "前足C/W", "min": 1.350, "max": 1.550},
      {"label": "後足C/W", "min": 2.150, "max": 2.350},
    ];

    return Center(
      child: SizedBox(
        width: 320,
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            border: Border.all(color: Colors.white, width: 0.3),
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
                  const SizedBox(height: 12),
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
              SizedBox(
                width: 100,
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
              SizedBox(
                width: 100,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "${minValue.toStringAsFixed(3)}～${maxValue.toStringAsFixed(3)}",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: fieldTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 0),
              Row(
                children: [
                  SizedBox(
                    width: 100,
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
                        hintStyle: TextStyle(color: hintColor, fontSize: 12),
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
