import 'package:flutter/material.dart';
import 'package:preharness/core/constants/app_colors.dart';
import 'package:preharness/core/themes/app_text_styles.dart';

/// アプリケーションのテーマ設定を管理するクラス
class AppTheme {
  /// ライトテーマの定義
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    fontFamily: 'NotoSansJP',

    // 背景色
    scaffoldBackgroundColor: AppColors.grayWhite,

    // プライマリカラー
    primarySwatch: _createMaterialColor(AppColors.blue),
    primaryColor: AppColors.blue,

    // アクセントカラー
    colorScheme: const ColorScheme.light(
      primary: AppColors.blue,
      secondary: AppColors.green,
      surface: AppColors.paperWhite,
      background: AppColors.grayWhite,
      error: AppColors.errorRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      onBackground: Colors.black87,
      onError: Colors.white,
    ),

    // テキストテーマ
    textTheme: AppTextStyles.lightTextTheme,

    // AppBarテーマ
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.paperWhite,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black87),
      titleTextStyle: TextStyle(
        fontFamily: 'NotoSansJP',
        color: Colors.black87,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // カードテーマ
    cardTheme: const CardThemeData(
      color: AppColors.paperWhite,
      elevation: 2,
      shadowColor: Colors.black12,
    ),

    // ボタンテーマ
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        textStyle: const TextStyle(
          fontFamily: 'NotoSansJP',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // テキストボタンテーマ
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.blue,
        textStyle: const TextStyle(
          fontFamily: 'NotoSansJP',
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // アウトラインボタンテーマ
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.blue,
        side: const BorderSide(color: AppColors.blue),
        textStyle: const TextStyle(
          fontFamily: 'NotoSansJP',
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // 入力フィールドテーマ
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.blue),
      ),
      labelStyle: TextStyle(
        fontFamily: 'NotoSansJP',
        color: Colors.black54,
      ),
    ),
  );

  /// ダークテーマの定義
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'NotoSansJP',

    // 背景色
    scaffoldBackgroundColor: AppColors.black,

    // プライマリカラー
    primarySwatch: _createMaterialColor(AppColors.neonGreen),
    primaryColor: AppColors.neonGreen,

    // アクセントカラー
    colorScheme: const ColorScheme.dark(
      primary: AppColors.neonGreen,
      secondary: AppColors.neonOrange,
      surface: AppColors.lightBlack,
      background: AppColors.black,
      error: AppColors.errorRed,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white,
    ),

    // テキストテーマ
    textTheme: AppTextStyles.darkTextTheme,

    // AppBarテーマ
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBlack,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontFamily: 'NotoSansJP',
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // カードテーマ
    cardTheme: const CardThemeData(
      color: AppColors.lightBlack,
      elevation: 4,
      shadowColor: Colors.black45,
    ),

    // ボタンテーマ
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neonGreen,
        foregroundColor: Colors.black,
        elevation: 2,
        textStyle: const TextStyle(
          fontFamily: 'NotoSansJP',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // テキストボタンテーマ
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.neonGreen,
        textStyle: const TextStyle(
          fontFamily: 'NotoSansJP',
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // アウトラインボタンテーマ
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.neonGreen,
        side: const BorderSide(color: AppColors.neonGreen),
        textStyle: const TextStyle(
          fontFamily: 'NotoSansJP',
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // 入力フィールドテーマ
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white54),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.neonGreen),
      ),
      labelStyle: TextStyle(
        fontFamily: 'NotoSansJP',
        color: Colors.white54,
      ),
    ),
  );

  /// MaterialColorを作成するヘルパーメソッド
  static MaterialColor _createMaterialColor(Color color) {
    final List strengths = <double>[.05];
    final Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (double strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}