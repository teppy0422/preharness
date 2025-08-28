import 'package:flutter/material.dart';
import 'package:preharness/utils/color_utils.dart';
import 'package:preharness/utils/global.dart';
import 'package:preharness/constants/app_colors.dart';

class ProductInfoCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 5,
              child: _buildLabelValue(
                '製品品番:',
                processingConditions['p_number'],
                valueFont: 28,
              ),
            ),
            Expanded(
              flex: 3,
              child: _buildLabelValue(
                'ロットNo:',
                processingConditions['lot_num'],
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
                processingConditions['eng_change'],
              ),
            ),
            Expanded(
              flex: 3,
              child: _buildLabelValue('構成No:', processingConditions['cfg_no']),
            ),
          ],
        ),
        SizedBox(height: 5),
        Row(
          children: [
            _buildLabelValue('色:', processingConditions['wire_color']),
          ],
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              flex: 5,
              child: _buildLabelValue(
                '準完日:',
                processingConditions['delivery_date'],
              ),
            ),
            Expanded(
              flex: 3,
              child: _buildLabelValue(
                '数量:',
                processingConditions['wire_cnt'],
                valueFont: 30,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                try {
                  onBack();
                } catch (e) {
                  print('Error in onBack: $e');
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('戻る'),
            ),
          ],
        ),
        Divider(
          height: 10,
          thickness: 0.5,
          color: AppColors.getLineColor(context),
        ),
        Row(
          children: [
            Expanded(
              flex: 5,
              child: _buildLabelValue('Applicator:', "7116-4727"),
            ),
            Expanded(flex: 3, child: _buildLabelValue('加締形状:', "2")),
            Expanded(flex: 3, child: _buildLabelValue('シリアルNo:', "17150")),
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
                color: containerColor ?? Colors.transparent,
                lineColor: containerForeColor ?? Colors.transparent,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
