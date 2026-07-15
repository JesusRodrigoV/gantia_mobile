import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/calibration_model.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
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
              child: Text(
                'No hay datos de calibración',
                style: TextStyle(fontSize: 13, color: context.surface500),
              ),
            )
          else
            ...service.entries.map((e) => _calibrationRow(e)),
          const SizedBox(height: Spacing.sm),
          GantiaButton(
            label: 'Iniciar Calibración',
            icon: Icons.sensors,
            variant: GantiaButtonVariant.primary,
            onPressed: () => _showCalibrationWizard(service),
          ),
        ],
      ),
    );
  }

  Widget _calibrationRow(CalibrationEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            entry.sensorName == 'flex_index'
                ? 'Índice'
                : entry.sensorName == 'flex_middle'
                    ? 'Medio'
                    : entry.sensorName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.surface700,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: context.surface100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${entry.minValue.toInt()} – ${entry.maxValue.toInt()}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.surface600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCalibrationWizard(CalibrationService service) {
    final calibMin = ValueNotifier<int?>(null);
    final calibMax = ValueNotifier<int?>(null);
    final calibSensor = ValueNotifier<String?>(null);

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final telemetry = ref.read(gloveStateProvider).telemetry;

            return AlertDialog(
              backgroundColor: context.surface0,
              title: Text(
                'Calibración',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.surface800,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1. Relajá el dedo y capturá el mínimo.\n'
                      '2. Flexioná completamente y capturá el máximo.\n'
                      '3. Guardá la calibración.',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.surface600,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),

                    if (telemetry != null) ...[
                      Text(
                        'Valores actuales:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.surface500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _liveFlexRow('Índice', telemetry.flexIndex),
                      _liveFlexRow('Medio', telemetry.flexMiddle),
                      const SizedBox(height: Spacing.sm),
                    ],

                    if (calibMin.value != null || calibMax.value != null) ...[
                      Container(
                        padding: const EdgeInsets.all(Spacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primary500.withAlpha(12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                size: 16, color: AppColors.primary500),
                            const SizedBox(width: 6),
                            Text(
                              calibMin.value != null && calibMax.value != null
                                  ? 'Mín: ${calibMin.value}  Máx: ${calibMax.value}'
                                  : calibMin.value != null
                                      ? 'Mínimo capturado: ${calibMin.value}'
                                      : 'Máximo capturado: ${calibMax.value}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.sm),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: GantiaButton(
                            label: 'Capturar Mín',
                            icon: Icons.arrow_downward,
                            variant: GantiaButtonVariant.default_,
                            onPressed: telemetry == null
                                ? null
                                : () => setDialogState(() {
                                      calibMin.value = telemetry.flexIndex;
                                      calibSensor.value = 'flex_index';
                                    }),
                          ),
                        ),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: GantiaButton(
                            label: 'Capturar Máx',
                            icon: Icons.arrow_upward,
                            variant: GantiaButtonVariant.default_,
                            onPressed: telemetry == null
                                ? null
                                : () => setDialogState(() {
                                      calibMax.value = telemetry.flexIndex;
                                      calibSensor.value = 'flex_index';
                                    }),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: context.surface500),
                  ),
                ),
                GantiaButton(
                  label: 'Guardar',
                  variant: GantiaButtonVariant.primary,
                  onPressed: calibMin.value == null || calibMax.value == null
                      ? null
                      : () async {
                          Navigator.of(ctx).pop();
                          await service.update(
                            calibSensor.value!,
                            minValue: calibMin.value!.toDouble(),
                            maxValue: calibMax.value!.toDouble(),
                          );
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _liveFlexRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12, color: context.surface600),
          ),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary500,
            ),
          ),
        ],
      ),
    );
  }
}
