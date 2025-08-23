import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:preharness/utils/color_utils.dart';

// 全角を半角に変換するTextInputFormatter
class HalfWidthTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = _toHalfWidth(newValue.text);
    return TextEditingValue(text: newText, selection: newValue.selection);
  }

  String _toHalfWidth(String s) {
    return s.replaceAllMapped(RegExp(r'[Ａ-Ｚａ-ｚ０-９　]'), (match) {
      final char = match.group(0)!;
      switch (char) {
        case '　':
          return ' ';
        default:
          return String.fromCharCode(char.codeUnitAt(0) - 0xFEE0);
      }
    });
  }
}

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

/// wire_colorから背景色と前景色を取得するヘルパー関数
///
/// [wireColorCode] wire_colorの値
/// 戻り値: {backColor: Color?, foreColor: Color?} のMap
Future<Map<String, Color?>> getWireColorsFromHive(String wireColorCode) async {
  final backColor = await getColorFromHive(wireColorCode);
  final foreColor = await getColorFromHive(wireColorCode, getForeColor: true);
  return {'backColor': backColor, 'foreColor': foreColor};
}

/// wire_colorに基づいてWireColorBoxウィジェットを作成するヘルパー関数
///
/// [wireColorCode] wire_colorの値
/// [width] WireColorBoxの幅 (デフォルト: 22)
/// [height] WireColorBoxの高さ (デフォルト: 22)
/// [strokeWidth] ラインの太さ (デフォルト: 5)
/// 戻り値: Future<WireColorBox>
Future<WireColorBox> createWireColorBox(
  String wireColorCode, {
  double width = 22,
  double height = 22,
  double strokeWidth = 5,
}) async {
  final colors = await getWireColorsFromHive(wireColorCode);
  return WireColorBox(
    width: width,
    height: height,
    color: colors['backColor'] ?? Colors.transparent,
    lineColor: colors['foreColor'] ?? Colors.transparent,
    strokeWidth: strokeWidth,
  );
}
