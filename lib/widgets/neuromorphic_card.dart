import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/shadows.dart';

class NeuromorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool showAccentLine;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;

  const NeuromorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.showAccentLine = true,
    this.borderRadius = 16,
    this.margin,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface900 = isDark ? AppColors.surfaceDark900 : AppColors.surfaceLight900;
    final surface0 = isDark ? AppColors.surfaceDark0 : AppColors.surfaceLight0;
    final bg = backgroundColor ?? (isDark ? AppColors.surfaceDark50 : AppColors.surfaceLight50);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: GantiaShadows.inset(surface900, surface0),
      ),
      child: Stack(
        children: [
          if (showAccentLine)
            Positioned(
              top: 0,
              left: 16,
              right: 16,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary500, AppColors.primary300, Colors.transparent],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(3),
                    bottomRight: Radius.circular(3),
                  ),
                ),
              ),
            ),
          Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class NeuromorphicCardInset extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const NeuromorphicCardInset({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface900 = isDark ? AppColors.surfaceDark900 : AppColors.surfaceLight900;
    final surface0 = isDark ? AppColors.surfaceDark0 : AppColors.surfaceLight0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark100 : AppColors.surfaceLight100,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: GantiaShadows.insetSm(surface900, surface0),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}
