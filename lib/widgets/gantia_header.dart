import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/shadows.dart';
import '../services/ws_service.dart';
import 'status_dot.dart';

class GantiaHeader extends StatelessWidget {
  final WsService wsService;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final VoidCallback onLogout;
  final bool scrolled;

  const GantiaHeader({
    super.key,
    required this.wsService,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onLogout,
    this.scrolled = false,
  });

  @override
  Widget build(BuildContext context) {
    final surface0 = isDarkMode ? AppColors.surfaceDark0 : AppColors.surfaceLight0;
    final surface900 = isDarkMode ? AppColors.surfaceDark900 : AppColors.surfaceLight900;
    final surface800 = isDarkMode ? AppColors.surfaceDark800 : AppColors.surfaceLight800;
    final surface600 = isDarkMode ? AppColors.surfaceDark600 : AppColors.surfaceLight600;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: surface0,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          ...GantiaShadows.elevated(surface900, surface0),
          if (scrolled)
            BoxShadow(
              color: AppColors.primary500.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Logo + Brand
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'G',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Gantia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: surface800,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Connection status
            StatusDot(
              status: wsService.connectionStatus,
              flowing: wsService.dataFlowing,
            ),
            const SizedBox(width: 8),

            // Mode badge
            if (wsService.dataFlowing)
              _ModeBadge(mode: wsService.currentMode),

            // Theme toggle
            IconButton(
              onPressed: onThemeToggle,
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                size: 20,
                color: surface600,
              ),
              style: IconButton.styleFrom(
                backgroundColor: surface0,
                elevation: 4,
                padding: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),

            // Logout
            IconButton(
              onPressed: onLogout,
              icon: Icon(Icons.logout, size: 20, color: surface600),
              style: IconButton.styleFrom(
                backgroundColor: surface0,
                elevation: 4,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark100 : AppColors.surfaceLight100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.surfaceDark900 : AppColors.surfaceLight900,
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
          BoxShadow(
            color: isDark ? AppColors.surfaceDark0 : AppColors.surfaceLight0,
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.category, size: 14, color: AppColors.primary500),
          const SizedBox(width: 4),
          Text(
            mode,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.surfaceLight700,
            ),
          ),
        ],
      ),
    );
  }
}
