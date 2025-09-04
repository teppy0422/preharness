import 'package:flutter/material.dart';
import 'package:preharness/constants/app_colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;

  const CustomCard({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.getCardColor(context),
      elevation: 4,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.getLineColor(context), width: 0.5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: Padding(padding: const EdgeInsets.all(8.0), child: child),
      ),
    );
  }
}
