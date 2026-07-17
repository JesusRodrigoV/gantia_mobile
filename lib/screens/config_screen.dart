import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../sections/absolute_pointer_section.dart';
import '../sections/calibration_section.dart';
import '../sections/gesture_config_section.dart';
import '../sections/import_export_section.dart';
import '../sections/learn_section.dart';
import '../sections/sync_reset_section.dart';
import '../sections/test_mode_section.dart';
import '../widgets/neuromorphic_card.dart';
import 'section_screen.dart';

class ConfigScreen extends ConsumerWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.surface50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                children: [
                  _menuItem(
                    context,
                    icon: Icons.gesture,
                    title: 'Gestos Configurados',
                    subtitle: 'Acciones asignadas a cada gesto manual',
                    child: const GestureConfigSection(),
                  ),
                  _menuItem(
                    context,
                    icon: Icons.tune,
                    title: 'Calibración',
                    subtitle: 'Ajuste de sensores del guante',
                    child: const CalibrationSection(),
                  ),
                  _menuItem(
                    context,
                    icon: Icons.near_me,
                    title: 'Puntero Absoluto',
                    subtitle: 'Mapeo de inclinación para puntero',
                    child: const AbsolutePointerSection(),
                  ),
                  _menuItem(
                    context,
                    icon: Icons.science,
                    title: 'Modo Prueba',
                    subtitle: 'Telemetría en vivo del guante',
                    child: const TestModeSection(),
                  ),
                  _menuItem(
                    context,
                    icon: Icons.file_download,
                    title: 'Importar / Exportar',
                    subtitle: 'Exportar o importar configuraciones',
                    child: const ImportExportSection(),
                  ),
                  _menuItem(
                    context,
                    icon: Icons.sync,
                    title: 'Sincronización',
                    subtitle: 'Sincronizar o restablecer configuraciones',
                    child: const SyncResetSection(),
                  ),
                  _menuItem(
                    context,
                    icon: Icons.school,
                    title: 'Aprender Gesto',
                    subtitle: 'Asistente de aprendizaje de gestos',
                    child: const LearnSection(),
                  ),
                  const SizedBox(height: Spacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: NeuromorphicCard(
        showAccentLine: false,
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SectionScreen(
                  icon: icon,
                  title: title,
                  child: child,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.md,
              ),
              child: Row(
                children: [
                  Icon(icon, size: 22, color: AppColors.primary500),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.surface800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: context.surface500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 20, color: context.surface400),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.md,
        Spacing.md,
        Spacing.xs,
      ),
      child: Row(
        children: [
          const Icon(Icons.tune, color: AppColors.primary500, size: 28),
          const SizedBox(width: Spacing.xs),
          Text(
            'Configuración de Gestos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: context.surface800,
            ),
          ),
        ],
      ),
    );
  }
}
