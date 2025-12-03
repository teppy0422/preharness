import 'package:flutter/material.dart';
import 'package:preharness/core/constants/app_colors.dart';
import 'package:preharness/core/utils/global.dart';
import 'package:preharness/shared/ui/pattern_button.dart';

class ProductInfoCard extends StatefulWidget {
  final Map<String, dynamic> processingConditions;
  final VoidCallback onBack;
  final Color? containerColor;
  final Color? containerForeColor;
  final String? quantity;

  const ProductInfoCard({
    super.key,
    required this.processingConditions,
    required this.onBack,
    this.containerColor,
    this.containerForeColor,
    this.quantity,
  });

  @override
  State<ProductInfoCard> createState() => _ProductInfoCardState();
}

class _ProductInfoCardState extends State<ProductInfoCard> {
  @override
  void initState() {
    super.initState();
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
            const SizedBox(width: 8),
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
