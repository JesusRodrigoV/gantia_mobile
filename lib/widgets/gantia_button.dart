import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/shadows.dart';

class GantiaButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final GantiaButtonVariant variant;
  final bool isLoading;
  final double? minWidth;
  final EdgeInsetsGeometry? padding;
  final bool expanded;

  const GantiaButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = GantiaButtonVariant.default_,
    this.isLoading = false,
    this.minWidth,
    this.padding,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;

    switch (variant) {
      case GantiaButtonVariant.primary:
        bgColor = AppColors.primary500;
        fgColor = Colors.white;
        break;
      case GantiaButtonVariant.danger:
        bgColor = context.surface0;
        fgColor = AppColors.red500;
        break;
      case GantiaButtonVariant.default_:
        bgColor = context.surface0;
        fgColor = AppColors.primary600;
    }

    final button = SizedBox(
      width: expanded ? double.infinity : minWidth,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? Semantics(
                label: 'Cargando',
                child: const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );

    if (variant == GantiaButtonVariant.primary) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: GantiaShadows.elevated(
            context.surface900,
            context.surface0,
          ),
        ),
        child: button,
      );
    }

    return button;
  }
}

enum GantiaButtonVariant { default_, primary, danger }
