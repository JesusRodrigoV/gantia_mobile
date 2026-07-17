import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/shadows.dart';
import '../theme/spacing.dart';
import '../providers.dart';
import 'gantia_scramble_text.dart';
import 'status_dot.dart';

class GantiaHeader extends ConsumerWidget {
  final bool scrolled;
  final VoidCallback onLogout;

  const GantiaHeader({
    super.key,
    this.scrolled = false,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeServiceProvider.select((s) => s.isDarkMode));
    final gloveState = ref.watch(gloveStateProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: context.surface0,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          ...GantiaShadows.elevated(context.surface900, context.surface0),
          if (scrolled)
            BoxShadow(
              color: AppColors.primary500.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logos/logo.webp',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Flexible(
              child: GantiaScrambleText(
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: context.surface800,
                ),
              ),
            ),

            const Spacer(),

            StatusDot(
              status: gloveState.connectionStatus,
              flowing: gloveState.dataFlowing,
            ),
            const SizedBox(width: Spacing.xs),

            if (gloveState.dataFlowing)
              _ModeBadge(mode: gloveState.currentMode),

            IconButton(
              onPressed: () => ref.read(themeServiceProvider).toggleTheme(),
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                size: 20,
                color: context.surface600,
              ),
              style: IconButton.styleFrom(
                backgroundColor: context.surface0,
                padding: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),

            IconButton(
              onPressed: onLogout,
              icon: Icon(Icons.logout, size: 20, color: context.surface600),
              style: IconButton.styleFrom(
                backgroundColor: context.surface0,
                padding: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              tooltip: 'Cerrar Sesión',
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  final String mode;

  const _ModeBadge({required this.mode});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.surface100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.surface900.withAlpha(15),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
          BoxShadow(
            color: context.surface0.withAlpha(204),
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.category, size: 14, color: AppColors.primary500),
          const SizedBox(width: Spacing.xxs),
          Text(
            mode,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.surface800,
            ),
          ),
        ],
      ),
    );
  }
}
