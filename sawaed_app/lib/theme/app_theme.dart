import 'package:flutter/material.dart';

/// ألوان وتنسيق تطبيق سواعد عربية
class AppColors {
  static const Color primary = Color(0xFFD07020);
  static const Color primaryDark = Color(0xFF8A4A10);
  static const Color primaryLight = Color(0xFFF0954A);
  static const Color primaryBg = Color(0xFFFFF3E0);

  static const Color success = Color(0xFF0F6E56);
  static const Color successBg = Color(0xFFE1F5EE);

  static const Color danger = Color(0xFFD30000);
  static const Color dangerBg = Color(0xFFFDE8E8);

  static const Color info = Color(0xFF185FA5);
  static const Color infoBg = Color(0xFFE8F0FF);

  static const Color textDark = Color(0xFF2C2C2A);
  static const Color textMuted = Color(0xFFADB5BD);
  static const Color background = Color(0xFFF0F2F5);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}
