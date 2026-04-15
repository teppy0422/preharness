import 'package:flutter/material.dart';
import 'package:preharness/core/constants/app_colors.dart';

class InfoIconButton extends StatelessWidget {
  final String title;
  final String content;
  final double iconSize;

  const InfoIconButton({
    super.key,
    required this.title,
    required this.content,
    this.iconSize = 20,
  });

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.getCardColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.getHighLightColor(context),
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getLineColor(context),
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getLineColor(context),
                height: 1.6,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '閉じる',
                style: TextStyle(
                  color: AppColors.getHighLightColor(context),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showInfoDialog(context),
      child: Tooltip(
        message: title,
        child: Icon(
          Icons.info_outline,
          size: iconSize,
          color: AppColors.getHighLightColor(context),
        ),
      ),
    );
  }
}
