import 'package:flutter/material.dart';

class AppColors {
  static const Color black = Color(0xFF000000);
  static const Color lightBlack = Color.fromARGB(255, 10, 10, 10);

  static const Color green = Color.fromARGB(255, 10, 99, 13); // ラベル緑
  static const Color lightGreen = Color.fromARGB(255, 234, 255, 235); // ラベル緑
  static const Color darkGreen = Color.fromARGB(255, 30, 60, 35);
  static const Color deepGreen = Color.fromARGB(255, 26, 173, 33);
  static const Color neonGreen = Color(0xFF39FF14); // Electric Green

  static const Color errorRed = Color(0xFFFF3B30);

  static const Color red = Color(0xFFF44336); // ラベル赤
  static const Color coralRed = Color.fromARGB(255, 225, 75, 25); //
  static const Color highlightOrange = Color(0xFFF57C00);

  static const Color teal = Color(0xFF009688); //
  static const Color olive = Color(0xFF708238); //
  static const Color blue = Color(0xFF2196F3); // ラベル青
  static const Color labelBackground = Color(0xFFF5F5F5); // ラベル背景色
  static const Color valueBackground = Color(0xFFFFFFFF); // 値背景色

  static const Color paperWhite = Color(0xFFFFFEFA);
  static const Color paperBlack = Color(0xFF1C1C1C);

  static const Color grayWhite = Color(0xFFEAE7E1);

  // 枠線などのデフォルト色
  static const Color border = Color(0xFFBDBDBD);

  static Color getHighLightColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? neonGreen : highlightOrange;
  }

  static Color getErrorColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? errorRed : errorRed;
  }

  static Color getLineColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? paperWhite : paperBlack;
  }

  static Color getLineSubColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color.fromARGB(255, 178, 177, 174) : paperBlack;
  }

  static Color getCardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? black : paperWhite;
  }

  // Lottie Color Converter
  static String colorToLottieRgb(Color color) {
    final r = (color.red / 255).toStringAsFixed(3);
    final g = (color.green / 255).toStringAsFixed(3);
    final b = (color.blue / 255).toStringAsFixed(3);
    return '[$r,$g,$b]';
  }

  static String colorToLottieRgba(Color color) {
    final r = (color.red / 255).toStringAsFixed(3);
    final g = (color.green / 255).toStringAsFixed(3);
    final b = (color.blue / 255).toStringAsFixed(3);
    // The original animation uses a fixed alpha of 1, so we'll do the same.
    return '[$r,$g,$b,1]';
  }
}