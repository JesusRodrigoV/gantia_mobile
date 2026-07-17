import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _base(
    colorScheme: AppColors.lightScheme(),
    surface0: AppColors.surfaceLight0,
    surface50: AppColors.surfaceLight50,
    surface100: AppColors.surfaceLight100,
    surface200: AppColors.surfaceLight200,
    surface300: AppColors.surfaceLight300,
    surface500: AppColors.surfaceLight500,
    surface600: AppColors.surfaceLight600,
    surface700: AppColors.surfaceLight700,
    surface800: AppColors.surfaceLight800,
    surface900: AppColors.surfaceLight900,
  );

  static ThemeData dark() => _base(
    colorScheme: AppColors.darkScheme(),
    surface0: AppColors.surfaceDark0,
    surface50: AppColors.surfaceDark50,
    surface100: AppColors.surfaceDark100,
    surface200: AppColors.surfaceDark200,
    surface300: AppColors.surfaceDark300,
    surface500: AppColors.surfaceDark500,
    surface600: AppColors.surfaceDark600,
    surface700: AppColors.surfaceDark700,
    surface800: AppColors.surfaceDark800,
    surface900: AppColors.surfaceDark900,
  );

  static final TextTheme _fontUi = GoogleFonts.cormorantGaramondTextTheme();
  static final TextStyle _labelSmall = GoogleFonts.notoSansTextTheme().labelSmall;

  static ThemeData _base({
    required ColorScheme colorScheme,
    required Color surface0,
    required Color surface50,
    required Color surface100,
    required Color surface200,
    required Color surface300,
    required Color surface500,
    required Color surface600,
    required Color surface700,
    required Color surface800,
    required Color surface900,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface50,
      textTheme: TextTheme(
        displayLarge: fontUi.displayLarge?.copyWith(color: surface800),
        displayMedium: fontUi.displayMedium?.copyWith(color: surface800),
        displaySmall: fontUi.displaySmall?.copyWith(color: surface800),
        headlineLarge: fontUi.headlineLarge?.copyWith(color: surface800),
        headlineMedium: fontUi.headlineMedium?.copyWith(color: surface800),
        headlineSmall: fontUi.headlineSmall?.copyWith(color: surface800),
        titleLarge: fontUi.titleLarge?.copyWith(color: surface800),
        titleMedium: fontUi.titleMedium?.copyWith(color: surface800),
        titleSmall: fontUi.titleSmall?.copyWith(color: surface800),
        bodyLarge: fontUi.bodyLarge?.copyWith(color: surface800),
        bodyMedium: fontUi.bodyMedium?.copyWith(color: surface800),
        bodySmall: fontUi.bodySmall?.copyWith(color: surface700),
        labelLarge: fontUi.labelLarge?.copyWith(color: surface800),
        labelMedium: fontUi.labelMedium?.copyWith(color: surface600),
        labelSmall: labelSmall?.copyWith(color: surface500),
      ),
      cardTheme: CardThemeData(
        color: surface50,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.red500, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.red500, width: 1.5),
        ),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: surface500,
          letterSpacing: 1,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          color: surface500,
        ),
        errorStyle: TextStyle(
          fontSize: 12,
          color: AppColors.red500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: surface0,
          foregroundColor: AppColors.primary600,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          shadowColor: Colors.transparent,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: surface500,
          textStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: surface200,
        thickness: 1,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.all(6),
        radius: const Radius.circular(3),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return surface300;
        }),
      ),
    );
  }
}
