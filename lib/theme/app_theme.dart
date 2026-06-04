import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'shadows.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _base(AppColors.lightScheme(), AppColors.surfaceLight0, AppColors.surfaceLight50, AppColors.surfaceLight100, AppColors.surfaceLight200, AppColors.surfaceLight300, AppColors.surfaceLight500, AppColors.surfaceLight600, AppColors.surfaceLight700, AppColors.surfaceLight800, AppColors.surfaceLight900);

  static ThemeData dark() => _base(AppColors.darkScheme(), AppColors.surfaceDark0, AppColors.surfaceDark50, AppColors.surfaceDark100, AppColors.surfaceDark200, AppColors.surfaceDark300, AppColors.surfaceDark500, AppColors.surfaceDark600, AppColors.surfaceDark700, AppColors.surfaceDark800, AppColors.surfaceDark900);

  static ThemeData _base(
    ColorScheme scheme,
    Color surface0,
    Color surface50,
    Color surface100,
    Color surface200,
    Color surface300,
    Color surface500,
    Color surface600,
    Color surface700,
    Color surface800,
    Color surface900,
  ) {
    final fontUi = GoogleFonts.cormorantGaramondTextTheme();
    final fontLabel = GoogleFonts.notoSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
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
        labelSmall: fontLabel.labelSmall?.copyWith(color: surface500),
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
          fontFamily: 'CormorantGaramond',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: surface500,
          letterSpacing: 1.5,
        ),
        hintStyle: TextStyle(
          fontFamily: 'CormorantGaramond',
          fontSize: 14,
          color: surface400,
        ),
        errorStyle: TextStyle(
          fontFamily: 'CormorantGaramond',
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
            fontFamily: 'CormorantGaramond',
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
            fontFamily: 'CormorantGaramond',
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
