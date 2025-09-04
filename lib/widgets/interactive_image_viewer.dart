import 'package:flutter/material.dart';
import 'package:preharness/constants/app_colors.dart';

class InteractiveImageViewer extends StatelessWidget {
  final String imagePath;
  final double scale;
  final double panX;
  final double panY;
  final double height;
  final double? width;

  const InteractiveImageViewer({
    super.key,
    required this.imagePath,
    this.scale = 1.0,
    this.panX = 0.0,
    this.panY = 0.0,
    this.height = 295,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return _FullScreenImageView(imagePath: imagePath);
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        );
      },
      child: Card(
        elevation: 3,
        child: SizedBox(
          height: height,
          width: width,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final viewWidth = constraints.maxWidth;
                    final viewHeight = constraints.maxHeight;

                    final calculatedPanX = -(viewWidth * panX * scale);
                    final calculatedPanY = -(viewHeight * panY * scale);

                    final image = ColorFiltered(
                      colorFilter: ColorFilter.matrix([
                        1.0, 0, 0, 0, 0,     // 赤: そのまま (255)
                        0, 0.996, 0, 0, 0,   // 緑: わずかに減らす (254)
                        0, 0, 0.98, 0, 0,    // 青: 少し減らす (250)
                        0, 0, 0, 1, 0,       // アルファ
                      ]),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                      ),
                    );

                    return InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 3.0,
                      transformationController: TransformationController(
                        Matrix4.identity()
                          ..translate(calculatedPanX, calculatedPanY)
                          ..scale(scale),
                      ),
                      child: isDark
                          ? ColorFiltered(
                              colorFilter: const ColorFilter.matrix([
                                -1,
                                0,
                                0,
                                0,
                                255,
                                0,
                                -1,
                                0,
                                0,
                                255,
                                0,
                                0,
                                -1,
                                0,
                                255,
                                0,
                                0,
                                0,
                                1,
                                0,
                              ]),
                              child: Image.asset(
                                imagePath,
                                fit: BoxFit.contain,
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                              ),
                            )
                          : image,
                    );
                  },
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.getLineColor(context),
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FullScreenImageView extends StatelessWidget {
  final String imagePath;

  const _FullScreenImageView({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final image = Image.asset(imagePath, fit: BoxFit.contain);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: isDark
                    ? ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          -1,
                          0,
                          0,
                          0,
                          255,
                          0,
                          -1,
                          0,
                          0,
                          255,
                          0,
                          0,
                          -1,
                          0,
                          255,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ]),
                        child: image,
                      )
                    : image,
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Text(
              'タップして戻る / ピンチで拡大縮小',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
