import 'dart:async';
import 'package:flutter/material.dart';
import 'package:preharness/constants/app_colors.dart';
import 'package:preharness/utils/global.dart';
import 'package:preharness/utils/shared_prefs_helper.dart';
import 'package:preharness/widgets/custom_input_card.dart';
import 'package:preharness/widgets/ui/pattern_button.dart';

class ProductInfoCard extends StatefulWidget {
  final Map<String, dynamic> processingConditions;
  final VoidCallback onBack;
  final Color? containerColor;
  final Color? containerForeColor;

  const ProductInfoCard({
    super.key,
    required this.processingConditions,
    required this.onBack,
    this.containerColor,
    this.containerForeColor,
  });

  @override
  State<ProductInfoCard> createState() => _ProductInfoCardState();
}

class _ProductInfoCardState extends State<ProductInfoCard> {
  String _micrometerSerialNumber = ""; // マイクロメーター

  String _applicatorName = ""; // Applicatorアプリ品番
  String _applicatorSerialNumber = ""; // Applicatorシリアル番号

  String _terminalName = ""; // 材料の端子品番
  String _terminalSerialNumber = ""; // 材料の端子ロットナンバー

  Future<void> _loadStringPref(String key, Function(String) setter) async {
    await SharedPrefsHelper.loadAndSetStringWithState(key, this, setter);
  }

  @override
  void initState() {
    super.initState();
    _loadAllPreferences();
  }

  Future<void> _loadAllPreferences() async {
    await _loadStringPref(
      'micrometer_serial_number', // これが保存名で呼び出し
      (value) => _micrometerSerialNumber = value, // これが変数にセット
    );
    await _loadStringPref(
      'applicator_name',
      (value) => _applicatorName = value,
    );
    await _loadStringPref(
      'applicator_serial_number',
      (value) => _applicatorSerialNumber = value,
    );
    await _loadStringPref('terminal_name', (value) => _terminalName = value);
    await _loadStringPref(
      'terminal_serial_number',
      (value) => _terminalSerialNumber = value,
    );
    // _loadTerminal();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PatternButton(
              label: "←Back",
              fontSize: 16,
              width: 64,
              height: 36,
              onPressed: () {
                try {
                  widget.onBack();
                } catch (e) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          color: AppColors.getCardColor(context),
          elevation: 4,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: AppColors.getLineColor(context),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(8.0), //
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildLabelValue(
                        '製品品番:',
                        widget.processingConditions['p_number'],
                        valueFont: 28,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: _buildLabelValue(
                        'ロットNo:',
                        widget.processingConditions['lot_num'],
                        valueFont: 28,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildLabelValue(
                        '設変:',
                        widget.processingConditions['eng_change'],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: _buildLabelValue(
                        '構成No:',
                        widget.processingConditions['cfg_no'],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    _buildLabelValue(
                      '色:',
                      widget.processingConditions['wire_color'],
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildLabelValue(
                        '準完日:',
                        widget.processingConditions['delivery_date'],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: _buildLabelValue(
                        '数量:',
                        widget.processingConditions['wire_cnt'],
                        valueFont: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 5),

        Divider(
          height: 16,
          thickness: 0.5,
          color: AppColors.getLineColor(context),
        ),
      ],
    );
  }

  Widget _buildLabelValue(
    String label,
    String value, {
    double labelFont = 11,
    double valueFont = 24,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: labelFont, height: 1.0)),
        Row(
          children: [
            Text(value, style: TextStyle(fontSize: valueFont, height: 1.0)),
            SizedBox(width: 2),
            if (label == '色:') ...[
              WireColorBox(
                width: 22,
                height: 22,
                color: widget.containerColor ?? Colors.transparent,
                lineColor: widget.containerForeColor ?? Colors.transparent,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
