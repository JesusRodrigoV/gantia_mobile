import 'package:flutter/material.dart';
import 'app_colors.dart';

extension ThemeColors on BuildContext {
  Color get surface0 => _surface(0);
  Color get surface50 => _surface(50);
  Color get surface100 => _surface(100);
  Color get surface200 => _surface(200);
  Color get surface300 => _surface(300);
  Color get surface400 => _surface(400);
  Color get surface500 => _surface(500);
  Color get surface600 => _surface(600);
  Color get surface700 => _surface(700);
  Color get surface800 => _surface(800);
  Color get surface900 => _surface(900);

  Color _surface(int shade) {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return switch (shade) {
      0 => isDark ? AppColors.surfaceDark0 : AppColors.surfaceLight0,
      50 => isDark ? AppColors.surfaceDark50 : AppColors.surfaceLight50,
      100 => isDark ? AppColors.surfaceDark100 : AppColors.surfaceLight100,
      200 => isDark ? AppColors.surfaceDark200 : AppColors.surfaceLight200,
      300 => isDark ? AppColors.surfaceDark300 : AppColors.surfaceLight300,
      400 => isDark ? AppColors.surfaceDark400 : AppColors.surfaceLight400,
      500 => isDark ? AppColors.surfaceDark500 : AppColors.surfaceLight500,
      600 => isDark ? AppColors.surfaceDark600 : AppColors.surfaceLight600,
      700 => isDark ? AppColors.surfaceDark700 : AppColors.surfaceLight700,
      800 => isDark ? AppColors.surfaceDark800 : AppColors.surfaceLight800,
      900 => isDark ? AppColors.surfaceDark900 : AppColors.surfaceLight900,
      _ => isDark ? AppColors.surfaceDark0 : AppColors.surfaceLight0,
    };
  }
}
