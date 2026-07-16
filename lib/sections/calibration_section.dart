import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calibration_model.dart';
import '../providers.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../widgets/calibration_wizard_dialog.dart';
import '../widgets/gantia_button.dart';
import '../widgets/settings_card.dart';
import '../widgets/skeleton_card.dart';

class CalibrationSection extends ConsumerStatefulWidget {
  const CalibrationSection({super.key});

  @override
  ConsumerState<CalibrationSection> createState() => _CalibrationSectionState();
}

class _CalibrationSectionState extends ConsumerState<CalibrationSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(calibrationServiceProvider).getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(calibrationServiceProvider);

    return SettingsCard(
      icon: Icons.tune,
      title: 'Calibración',
      description: 'Ajustar sensores del guante',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (service.isLoading && service.entries.isEmpty)
            const SkeletonCard(height: 60, lines: 1)
          else if (service.entries.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: Text('No hay datos de calibración',
                style: TextStyle(fontSize: 13, color: context.surface500)),
            )
          else
            ...service.entries.map((e) => _calibrationRow(e)),
          const SizedBox(height: Spacing.sm),
          GantiaButton(
            label: 'Iniciar Calibración',
            icon: Icons.sensors,
            variant: GantiaButtonVariant.primary,
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const CalibrationWizardDialog(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _calibrationRow(CalibrationEntry entry) {
    final name = switch (entry.sensorName) {
      'flex_index' => 'Índice',
      'flex_middle' => 'Medio',
      _ => entry.sensorName,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Text(name,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.surface700)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: context.surface100, borderRadius: BorderRadius.circular(6)),
          child: Text('${entry.minValue.toInt()} – ${entry.maxValue.toInt()}',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.surface600)),
        ),
      ]),
    );
  }
}
