import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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

  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark50
            : AppColors.surfaceLight50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark900
                : AppColors.surfaceLight900,
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark0
                : AppColors.surfaceLight0,
            blurRadius: 8,
            offset: const Offset(-4, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: AppColors.primary500),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: const TextStyle(
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
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.surfaceLight500,
                ),
              ),
            ],
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
