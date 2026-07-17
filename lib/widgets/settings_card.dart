import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/shadows.dart';
import '../theme/spacing.dart';

class SettingsCard extends StatelessWidget {
  final String title;
  final String? description;
  final Widget child;
  final IconData? icon;

  const SettingsCard({
    super.key,
    required this.title,
    this.description,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Spacing.md),
      decoration: BoxDecoration(
        color: context.surface50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: GantiaShadows.inset(Theme.of(context).brightness),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: AppColors.primary500),
                  const SizedBox(width: Spacing.xs),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.08,
                    color: AppColors.primary600,
                  ),
                ),
              ],
            ),
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(
                description!,
                style: TextStyle(
                  fontSize: 12,
                  color: context.surface500,
                ),
              ),
            ],
            const SizedBox(height: Spacing.md),
            child,
          ],
        ),
      ),
    );
  }
}
