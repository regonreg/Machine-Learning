import 'package:flutter/material.dart';

class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color accent = Color(0xFF00ACC1);

  // Backgrounds
  static const Color bgDark = Color(0xFF0F1923);
  static const Color bgCard = Color(0xFF162032);
  static const Color bgCardLight = Color(0xFF1E2D42);
  static const Color bgSurface = Color(0xFF1A2840);

  // Status colors
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFAB00);
  static const Color danger = Color(0xFFFF1744);
  static const Color info = Color(0xFF00B0FF);

  // Text
  static const Color textPrimary = Color(0xFFECF0F1);
  static const Color textSecondary = Color(0xFF8899AA);
  static const Color textMuted = Color(0xFF546E7A);

  // Border
  static const Color border = Color(0xFF243447);
  static const Color borderLight = Color(0xFF2D4260);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF00ACC1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0F1923), Color(0xFF162032)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient cardGradient = LinearGradient(
    colors: [
      const Color(0xFF162032),
      const Color(0xFF1E2D42),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgDark,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.bgCard,
          error: AppColors.danger,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.bgCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.bgCardLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          hintStyle: const TextStyle(color: AppColors.textMuted),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
}
