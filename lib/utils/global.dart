import 'package:flutter/material.dart';

// 部品品番の表示
String formatCode(String value, String sep) {
  if (value.length == 8) {
    return "${value.substring(0, 4)}$sep${value.substring(4, 8)}";
  } else if (value.length == 10) {
    return "${value.substring(0, 4)}$sep${value.substring(4, 8)}$sep${value.substring(8, 10)}";
  }
  return value;
}

class WireColorBox extends StatelessWidget {
  final Color color;
  final Color lineColor;
  final double width;
  final double height;
  final double strokeWidth;

  const WireColorBox({
    super.key,
    required this.color,
    required this.lineColor,
    this.width = 22,
    this.height = 22,
    this.strokeWidth = 5,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 背景色
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            border: isDark
                ? Border.all(color: Colors.white, width: 0.5)
                : Border.all(color: Colors.black, width: 0.5),
          ),
        ),
        // 斜め線
        ClipRect(
          child: CustomPaint(
            size: Size(width - 1.2, height - 1.2),
            painter: WireColorLine(
              lineColor: lineColor,
              strokeWidth: strokeWidth,
            ),
          ),
        ),
      ],
    );
  }
}

class WireColorLine extends CustomPainter {
  final Color lineColor;
  final double strokeWidth;

  WireColorLine({required this.lineColor, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
