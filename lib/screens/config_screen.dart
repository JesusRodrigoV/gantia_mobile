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
                  const GestureConfigSection(),
                  const CalibrationSection(),
                  const AbsolutePointerSection(),
                  const TestModeSection(),
                  const ImportExportSection(),
                  const SyncResetSection(),
                  const LearnSection(),
                  const SizedBox(height: Spacing.xxl),
                ],
              ),
            ),
          ],
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
