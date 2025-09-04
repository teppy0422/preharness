import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:preharness/constants/app_colors.dart';
import 'package:preharness/utils/global.dart';
import 'package:preharness/widgets/custom_input_card.dart';
import 'package:preharness/widgets/ui/pattern_button.dart';
import 'package:preharness/widgets/ui/custom_card.dart';

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
  String _micrometerSerialNumber = ""; // デフォルト値
  String _applicatorName = ""; // Applicatorアプリ品番
  String _applicatorSerialNumber = ""; //Applicatorシリアル番号
  String _terminalName = "";
  String _terminalLotNumber = "";

  @override
  void initState() {
    super.initState();
    _loadMicrometerSerialNumber();
    _loadApplicator();
    _loadTerminal();
  }

  Future<void> _loadMicrometerSerialNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNumber = prefs.getString('micrometer_serial_number');
    if (savedNumber != null) {
      setState(() {
        _micrometerSerialNumber = savedNumber;
      });
    }
  }

  Future<void> _loadApplicator() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('applicator_name');
    if (savedName != null) {
      setState(() {
        // 文字数が足りない場合にエラーにならないようガードを入れる
        if (savedName.length > 10) {
          _applicatorName = savedName.substring(0, 10); // 0〜9文字目（最初の10文字）
          _applicatorSerialNumber = savedName.substring(
            10,
          ); // 10文字目以降（index=10から最後まで）
        } else {
          // 10文字未満の場合のフォールバック処理
          _applicatorName = savedName;
          _applicatorSerialNumber = '';
        }
      });
    }
  }

  Future<void> _loadTerminal() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('terminal_name');
    if (savedName != null) {
      setState(() {
        // 文字数が足りない場合にエラーにならないようガードを入れる
        if (savedName.length > 10) {
          _terminalName = savedName.substring(0, 10); // 0〜9文字目（最初の10文字）
          _terminalLotNumber = savedName.substring(
            10,
          ); // 10文字目以降（index=10から最後まで）
        } else {
          // 10文字未満の場合のフォールバック処理
          _terminalName = savedName;
          _terminalLotNumber = '';
        }
      });
    }
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
        Divider(
          height: 1,
          thickness: 0.5,
          color: AppColors.getLineColor(context),
        ),
        const SizedBox(height: 6),
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
        Column(
          children: [
            CustomInputCard(
              title: 'マイクロメーター',
              subItems: [
                SubItem(
                  label: '管理No:',
                  value: _micrometerSerialNumber,
                  valueFont: 20,
                  flex: 5,
                  prefsKey: 'micrometer_serial_number',
                  onInputComplete: (value) {
                    setState(() {
                      _micrometerSerialNumber = value;
                    });
                  },
                ),
              ],
            ),
            CustomInputCard(
              title: 'Applicator Serial',
              subItems: [
                SubItem(
                  label: 'アプリ品番:',
                  value: _applicatorName,
                  valueFont: 20,
                  flex: 5,
                  prefsKey: 'applicator_name',
                  onInputComplete: (value) {
                    setState(() {
                      _applicatorName = value;
                    });
                  },
                ),
                SubItem(label: '加締形状:', value: '-', valueFont: 20, flex: 3),
                SubItem(
                  label: 'シリアルNo:',
                  value: _applicatorSerialNumber,
                  valueFont: 20,
                  flex: 3,
                ),
              ],
            ),
            CustomInputCard(
              title: '端子リール',
              subItems: [
                SubItem(
                  label: '端子品番:',
                  value: _terminalName,
                  valueFont: 20,
                  flex: 5,
                  prefsKey: 'terminal_name',
                  onInputComplete: (value) {
                    setState(() {
                      _terminalName = value;
                    });
                  },
                ),
                SubItem(
                  label: 'ロットNo:',
                  value: _terminalLotNumber,
                  valueFont: 20,
                  flex: 3,
                ),
              ],
            ),
          ],
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
