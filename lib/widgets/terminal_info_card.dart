import 'package:flutter/material.dart';
import 'package:preharness/core/constants/app_colors.dart';
import 'package:preharness/utils/global.dart';
import 'package:preharness/widgets/ui/pattern_button.dart';

class TerminalInfoCard extends StatelessWidget {
  final String? terminal1;
  final String? terminal2;
  final String wireType;
  final String wireSize;
  final String? cfgNo;
  final VoidCallback? onCfmTap;

  const TerminalInfoCard({
    super.key,
    this.terminal1,
    this.terminal2,
    required this.wireType,
    required this.wireSize,
    this.cfgNo,
    this.onCfmTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: AppColors.getCardColor(context),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.getLineColor(context), width: .5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatCode(terminal1 ?? "", "-"),
                      style: TextStyle(
                        color: AppColors.getLineColor(context),
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '$wireType / $wireSize',
                      style: TextStyle(
                        color: AppColors.getLineColor(context),
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      formatCode(terminal2 ?? "", "-"),
                      style: TextStyle(
                        fontSize: 20,
                        color: AppColors.getLineColor(context),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  if (cfgNo != null && onCfmTap != null)
                    Expanded(
                      child: Row(
                        children: [
                          PatternButton(
                            label: 'CFM:002',
                            fontSize: 14,
                            width: 90,
                            height: 32,
                            onPressed: onCfmTap!,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
