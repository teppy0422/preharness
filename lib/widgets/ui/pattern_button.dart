import 'package:flutter/material.dart';
import "package:preharness/constants/app_colors.dart";

class PatternButton extends StatelessWidget {
  final String label;
  final double fontSize;
  final double width;
  final double height;
  final VoidCallback onPressed;

  const PatternButton({
    super.key,
    required this.label,
    required this.fontSize,
    required this.width,
    required this.height,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 1,
          backgroundColor: AppColors.getCardColor(context), // デフォルト塗りつぶしを無効化
        ),
        onPressed: onPressed,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Ink(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.getLineColor(context),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: CustomPaint(
              painter: DiagonalStripesPainter(
                color: AppColors.getLineColor(context),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: AppColors.getLineColor(context),
                    fontWeight: FontWeight.bold,
                    shadows: <Shadow>[
                      // 4方向へのオフセットで、ぼかし具合を変えずに太い縁取りを作成
                      Shadow(
                        color: AppColors.getCardColor(context),
                        blurRadius: 2.0,
                        offset: Offset(2, 2),
                      ),
                      Shadow(
                        color: AppColors.getCardColor(context),
                        blurRadius: 2.0,
                        offset: Offset(-2, 2),
                      ),
                      Shadow(
                        color: AppColors.getCardColor(context),
                        blurRadius: 2.0,
                        offset: Offset(2, -2),
                      ),
                      Shadow(
                        color: AppColors.getCardColor(context),
                        blurRadius: 2.0,
                        offset: Offset(-2, -2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 斜線パターンを描く CustomPainter
class DiagonalStripesPainter extends CustomPainter {
  final Color color;

  DiagonalStripesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha(80)
      ..strokeWidth = 2;

    const double step = 8; // 斜線の間隔

    for (double i = -size.height; i < size.width; i += step) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
