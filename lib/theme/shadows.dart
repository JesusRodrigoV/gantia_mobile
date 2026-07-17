import 'package:flutter/material.dart';
import 'app_colors.dart';

class GantiaShadows {
  GantiaShadows._();

  static final Map<Brightness, List<BoxShadow>> _elevated = {};
  static final Map<Brightness, List<BoxShadow>> _inset = {};
  static final Map<Brightness, List<BoxShadow>> _elevatedSm = {};
  static final Map<Brightness, List<BoxShadow>> _insetSm = {};

  static List<BoxShadow> elevated(Brightness b) =>
      _elevated.putIfAbsent(b, () => [
        BoxShadow(
          offset: const Offset(8, 8),
          blurRadius: 16,
          color: _c(b, 900).withAlpha(15),
        ),
        BoxShadow(
          offset: const Offset(-8, -8),
          blurRadius: 16,
          color: _c(b, 0).withAlpha(204),
        ),
      ]);

  static List<BoxShadow> inset(Brightness b) =>
      _inset.putIfAbsent(b, () => [
        BoxShadow(
          offset: const Offset(4, 4),
          blurRadius: 8,
          color: _c(b, 900).withAlpha(15),
        ),
        BoxShadow(
          offset: const Offset(-4, -4),
          blurRadius: 8,
          color: _c(b, 0).withAlpha(204),
        ),
      ]);

  static List<BoxShadow> elevatedSm(Brightness b) =>
      _elevatedSm.putIfAbsent(b, () => [
        BoxShadow(
          offset: const Offset(4, 4),
          blurRadius: 8,
          color: _c(b, 900).withAlpha(15),
        ),
        BoxShadow(
          offset: const Offset(-4, -4),
          blurRadius: 8,
          color: _c(b, 0).withAlpha(204),
        ),
      ]);

  static List<BoxShadow> insetSm(Brightness b) =>
      _insetSm.putIfAbsent(b, () => [
        BoxShadow(
          offset: const Offset(2, 2),
          blurRadius: 4,
          color: _c(b, 900).withAlpha(15),
        ),
        BoxShadow(
          offset: const Offset(-2, -2),
          blurRadius: 4,
          color: _c(b, 0).withAlpha(204),
        ),
      ]);

  static Color _c(Brightness b, int shade) {
    return b == Brightness.dark
        ? (shade == 0
            ? AppColors.surfaceDark0
            : shade == 50
                ? AppColors.surfaceDark50
                : shade == 100
                    ? AppColors.surfaceDark100
                    : shade == 200
                        ? AppColors.surfaceDark200
                        : shade == 300
                            ? AppColors.surfaceDark300
                            : AppColors.surfaceDark900)
        : (shade == 0
            ? AppColors.surfaceLight0
            : shade == 50
                ? AppColors.surfaceLight50
                : shade == 100
                    ? AppColors.surfaceLight100
                    : shade == 200
                        ? AppColors.surfaceLight200
                        : shade == 300
                            ? AppColors.surfaceLight300
                            : AppColors.surfaceLight900);
  }
}
