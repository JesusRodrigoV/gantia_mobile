import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary — Teal
  static const Color primary50 = Color(0xFFe6f2f2);
  static const Color primary100 = Color(0xFFcce5e5);
  static const Color primary200 = Color(0xFF99cccc);
  static const Color primary300 = Color(0xFF66b2b2);
  static const Color primary400 = Color(0xFF339999);
  static const Color primary500 = Color(0xFF008080);
  static const Color primary600 = Color(0xFF006666);
  static const Color primary700 = Color(0xFF004d4d);
  static const Color primary800 = Color(0xFF003333);
  static const Color primary900 = Color(0xFF001a1a);
  static const Color primary950 = Color(0xFF000d0d);

  // Surface — Light (warm taupe)
  static const Color surfaceLight0 = Color(0xFFfcfaf5);
  static const Color surfaceLight50 = Color(0xFFf5f2eb);
  static const Color surfaceLight100 = Color(0xFFebe5da);
  static const Color surfaceLight200 = Color(0xFFd4cec4);
  static const Color surfaceLight300 = Color(0xFFb8b2a6);
  static const Color surfaceLight400 = Color(0xFF9c9588);
  static const Color surfaceLight500 = Color(0xFF7d776b);
  static const Color surfaceLight600 = Color(0xFF5e5950);
  static const Color surfaceLight700 = Color(0xFF3f3b35);
  static const Color surfaceLight800 = Color(0xFF2c2820);
  static const Color surfaceLight900 = Color(0xFF1a1814);

  // Surface — Dark (warm near-black)
  static const Color surfaceDark0 = Color(0xFF1c1a17);
  static const Color surfaceDark50 = Color(0xFF242220);
  static const Color surfaceDark100 = Color(0xFF2d2a26);
  static const Color surfaceDark200 = Color(0xFF3a3732);
  static const Color surfaceDark300 = Color(0xFF4a4640);
  static const Color surfaceDark400 = Color(0xFF5c5850);
  static const Color surfaceDark500 = Color(0xFF7d776b);
  static const Color surfaceDark600 = Color(0xFF9c9588);
  static const Color surfaceDark700 = Color(0xFFb8b2a6);
  static const Color surfaceDark800 = Color(0xFFd4cec4);
  static const Color surfaceDark900 = Color(0xFFebe5da);

  // Accent
  static const Color gold500 = Color(0xFFb8942e);

  // Semantic
  static const Color red400 = Color(0xFFf87171);
  static const Color red500 = Color(0xFFef4444);
  static const Color red600 = Color(0xFFdc2626);
  static const Color warning500 = Color(0xFFeab308);
  static const Color warning600 = Color(0xFFca8a04);
  static const Color cyan500 = Color(0xFF06b6d4);
  static const Color cyan600 = Color(0xFF0891b2);
  static const Color green500 = Color(0xFF22c55e);
  static const Color green600 = Color(0xFF16a34a);
  static const Color amber500 = Color(0xFFf59e0b);
  static const Color amber600 = Color(0xFFd97706);
  static const Color amber700 = Color(0xFFb45309);
  static const Color purple500 = Color(0xFFa855f7);
  static const Color purple600 = Color(0xFF9333ea);

  static ColorScheme lightScheme() => ColorScheme(
        brightness: Brightness.light,
        primary: primary500,
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: primary100,
        onPrimaryContainer: primary900,
        secondary: primary500,
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: primary50,
        onSecondaryContainer: primary800,
        surface: surfaceLight0,
        onSurface: surfaceLight800,
        surfaceContainerHighest: surfaceLight50,
        onSurfaceVariant: surfaceLight500,
        outline: surfaceLight300,
        error: red500,
        onError: Color(0xFFFFFFFF),
        errorContainer: surfaceLight100,
        onErrorContainer: red600,
      );

  static ColorScheme darkScheme() => ColorScheme(
        brightness: Brightness.dark,
        primary: primary500,
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: primary800,
        onPrimaryContainer: primary200,
        secondary: primary500,
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: primary800,
        onSecondaryContainer: primary200,
        surface: surfaceDark0,
        onSurface: surfaceDark800,
        surfaceContainerHighest: surfaceDark50,
        onSurfaceVariant: surfaceDark500,
        outline: surfaceDark300,
        error: red400,
        onError: Color(0xFF000000),
        errorContainer: surfaceDark100,
        onErrorContainer: red400,
      );
}
