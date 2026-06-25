import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';

class GantiaButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final GantiaButtonVariant variant;
  final bool isLoading;
  final double? minWidth;
  final EdgeInsetsGeometry? padding;

  const GantiaButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = GantiaButtonVariant.default_,
    this.isLoading = false,
    this.minWidth,
    this.padding,
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

    return SizedBox(
      width: minWidth,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

enum GantiaButtonVariant { default_, primary, danger }
