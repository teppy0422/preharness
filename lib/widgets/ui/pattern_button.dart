import 'package:flutter/material.dart';
import 'package:preharness/core/constants/app_colors.dart';

class PatternButton extends StatefulWidget {
  final String label;
  final double fontSize;
  final double width;
  final double height;
  final VoidCallback onPressed;
  final bool enableAnimation; // アニメーションの有効/無効
  final IconData? icon; // アイコン（オプション）
  final double iconSize; // アイコンサイズ
  final double iconTextSpacing; // アイコンとテキストの間隔

  const PatternButton({
    super.key,
    required this.label,
    required this.fontSize,
    required this.width,
    required this.height,
    required this.onPressed,
    this.enableAnimation = true,
    this.icon,
    this.iconSize = 16,
    this.iconTextSpacing = 4,
  });

  @override
  State<PatternButton> createState() => _PatternButtonState();
}

class _PatternButtonState extends State<PatternButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2), // 2秒で1サイクル
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    if (widget.enableAnimation) {
      _animationController.repeat(); // 無限ループ
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 1,
          backgroundColor: AppColors.getCardColor(context),
        ),
        onPressed: widget.onPressed,
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
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: DiagonalStripesPainter(
                    color: AppColors.getLineColor(context),
                    alpha: isDark ? 60 : 40,
                    animationOffset: widget.enableAnimation ? _animation.value : 0.0,
                  ),
                  child: Center(
                    child: widget.icon != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.icon,
                                size: widget.iconSize,
                                color: AppColors.getLineColor(context),
                              ),
                              SizedBox(width: widget.iconTextSpacing),
                              Text(
                                widget.label,
                                style: TextStyle(
                                  fontSize: widget.fontSize,
                                  color: AppColors.getLineColor(context),
                                  fontWeight: FontWeight.bold,
                                  shadows: <Shadow>[
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
                            ],
                          )
                        : Text(
                            widget.label,
                            style: TextStyle(
                              fontSize: widget.fontSize,
                              color: AppColors.getLineColor(context),
                              fontWeight: FontWeight.bold,
                              shadows: <Shadow>[
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
                );
              },
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
  final int alpha;
  final double animationOffset;

  DiagonalStripesPainter({
    required this.color,
    required this.alpha,
    this.animationOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha(alpha)
      ..strokeWidth = 2;

    const double step = 8; // 斜線の間隔

    // アニメーションオフセットを適用（左から右へ移動）
    final double offset = animationOffset * step;

    for (double i = -size.height - step; i < size.width + step; i += step) {
      final double animatedX = i + offset;
      canvas.drawLine(
        Offset(animatedX, 0),
        Offset(animatedX + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is DiagonalStripesPainter &&
           oldDelegate.animationOffset != animationOffset;
  }
}
