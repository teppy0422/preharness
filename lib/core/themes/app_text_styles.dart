import 'package:flutter/material.dart';

/// アプリケーション全体で使用するテキストスタイル定義
class AppTextStyles {
  // フォントファミリー定数
  static const String _primaryFont = 'NotoSansJP';    // 日本語メイン
  static const String _titleFont = 'Montserrat';      // 英語タイトル
  static const String _monoFont = 'RobotoMono';       // コード・数値表示
  // static const String _bodyFont = 'Inter';            // 英語本文（将来使用予定）

  /// ライトテーマ用テキストスタイル
  static TextTheme get lightTextTheme => const TextTheme(
    // 大見出し - 英語タイトル用
    headlineLarge: TextStyle(
      fontFamily: _titleFont,
      fontWeight: FontWeight.w700,
      fontSize: 32,
      color: Colors.black87,
    ),
    headlineMedium: TextStyle(
      fontFamily: _titleFont,
      fontWeight: FontWeight.w600,
      fontSize: 24,
      color: Colors.black87,
    ),
    headlineSmall: TextStyle(
      fontFamily: _primaryFont,
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: Colors.black87,
    ),

    // タイトル
    titleLarge: TextStyle(
      fontFamily: _primaryFont,
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: Colors.black87,
    ),
    titleMedium: TextStyle(
      fontFamily: _primaryFont,
      fontWeight: FontWeight.w500,
      fontSize: 16,
      color: Colors.black87,
    ),
    titleSmall: TextStyle(
      fontFamily: _primaryFont,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: Colors.black87,
    ),

    // 本文テキスト
    bodyLarge: TextStyle(
      fontFamily: _primaryFont,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      color: Colors.black87,
    ),
    bodyMedium: TextStyle(
      fontFamily: _primaryFont,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: Colors.black87,
    ),
    bodySmall: TextStyle(
      fontFamily: _primaryFont,
      fontWeight: FontWeight.w400,
      fontSize: 12,
      color: Colors.black54,
    ),

    // ラベル - ボタンやコード表示用
    labelLarge: TextStyle(
      fontFamily: _monoFont,
      fontWeight: FontWeight.w500,
      fontSize: 16,
      color: Colors.black87,
    ),
    labelMedium: TextStyle(
      fontFamily: _monoFont,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: Colors.black87,
    ),
    labelSmall: TextStyle(
      fontFamily: _monoFont,
      fontWeight: FontWeight.w400,
      fontSize: 12,
      color: Colors.black54,
    ),
  );

  /// ダークテーマ用テキストスタイル
  static TextTheme get darkTextTheme => const TextTheme(
    // 大見出し - 英語タイトル用
    headlineLarge: TextStyle(
      fontFamily: _titleFont,
      fontWeight: FontWeight.w700,
      fontSize: 32,
      color: Colors.white,
    ),
    headlineMedium: TextStyle(
      fontFamily: _titleFont,
      fontWeight: FontWeight.w600,
      fontSize: 24,
      color: Colors.white,
    ),
    headlineSmall: TextStyle(
      fontFamily: _primaryFont,
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: Colors.white,
    ),

    // タイトル
    titleLarge: TextStyle(
      fontFamily: _primaryFont,
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: Colors.white,
    ),
    titleMedium: TextStyle(
      fontFamily: _primaryFont,
      fontWeight: FontWeight.w500,
      fontSize: 16,
      color: Colors.white,
    ),
    titleSmall: TextStyle(
      fontFamily: _primaryFont,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: Colors.white,
    ),

    // 本文テキスト
    bodyLarge: TextStyle(
      fontFamily: _primaryFont,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      color: Colors.white,
    ),
    bodyMedium: TextStyle(
      fontFamily: _primaryFont,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: Colors.white,
    ),
    bodySmall: TextStyle(
      fontFamily: _primaryFont,
      fontWeight: FontWeight.w400,
      fontSize: 12,
      color: Colors.white70,
    ),

    // ラベル - ボタンやコード表示用
    labelLarge: TextStyle(
      fontFamily: _monoFont,
      fontWeight: FontWeight.w500,
      fontSize: 16,
      color: Colors.white,
    ),
    labelMedium: TextStyle(
      fontFamily: _monoFont,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: Colors.white,
    ),
    labelSmall: TextStyle(
      fontFamily: _monoFont,
      fontWeight: FontWeight.w400,
      fontSize: 12,
      color: Colors.white70,
    ),
  );

  /// よく使用される特殊なテキストスタイル
  static const TextStyle codeStyle = TextStyle(
    fontFamily: _monoFont,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.5,
  );

  static const TextStyle numberStyle = TextStyle(
    fontFamily: _monoFont,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: 0.5,
  );

  static const TextStyle brandStyle = TextStyle(
    fontFamily: _titleFont,
    fontWeight: FontWeight.w700,
    fontSize: 24,
    letterSpacing: -0.5,
  );
}