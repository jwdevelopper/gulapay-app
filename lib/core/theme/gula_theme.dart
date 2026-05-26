import 'package:flutter/material.dart';

final class GulaColors {
  GulaColors._();

  static const background = Color(0xFFFBF8F1);
  static const canvas = Color(0xFFEEE7D7);
  static const surface = Color(0xFFF6F0E3);
  static const surfaceAlt = Color(0xFFFFFDF8);
  static const border = Color(0xFFD9CCB7);
  static const borderSoft = Color(0xFFE7DCCB);
  static const text = Color(0xFF3D2D1F);
  static const textMuted = Color(0xFF8D745E);
  static const primary = Color(0xFFD96A3A);
  static const primarySoft = Color(0xFFE59A66);
  static const success = Color(0xFFD5B07C);
  static const warning = Color(0xFFE3C15D);
  static const danger = Color(0xFFD86A3B);
  static const free = Color(0xFFEFE7D6);
  static const occupied = Color(0xFFC8A27D);
  static const attention = Color(0xFFE8C65A);
  static const critical = Color(0xFFD66A3A);
}

final class GulaTheme {
  GulaTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: GulaColors.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: GulaColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: GulaColors.background,
        foregroundColor: GulaColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: GulaColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: GulaColors.border),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: GulaColors.surface,
        selectedColor: GulaColors.primary,
        secondarySelectedColor: GulaColors.primary,
        labelStyle: const TextStyle(
          color: GulaColors.text,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: GulaColors.border),
        ),
        side: const BorderSide(color: GulaColors.border),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GulaColors.surfaceAlt,
        hintStyle: const TextStyle(color: GulaColors.textMuted),
        labelStyle: const TextStyle(color: GulaColors.text),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: GulaColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: GulaColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: GulaColors.primary, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GulaColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: GulaColors.primarySoft.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: GulaColors.text,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: GulaColors.text,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: GulaColors.text,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(color: GulaColors.text),
        bodyMedium: TextStyle(color: GulaColors.text),
        bodySmall: TextStyle(color: GulaColors.textMuted),
      ),
      dividerColor: GulaColors.borderSoft,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: GulaColors.text,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      useMaterial3: true,
    );
  }
}
