import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import 'gantia_button.dart';

class CalibrationWizardDialog extends ConsumerStatefulWidget {
  const CalibrationWizardDialog({super.key});

  @override
  ConsumerState<CalibrationWizardDialog> createState() => _CalibrationWizardDialogState();
}

class _CalibrationWizardDialogState extends ConsumerState<CalibrationWizardDialog> {
  final _min = ValueNotifier<int?>(null);
  final _max = ValueNotifier<int?>(null);
  final _sensor = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    _sensor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final telemetry = ref.read(gloveStateProvider).telemetry;

    return AlertDialog(
      backgroundColor: context.surface0,
      title: Text('Calibración',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.surface800)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Relajá el dedo y capturá el mínimo.\n'
                '2. Flexioná completamente y capturá el máximo.\n'
                '3. Guardá la calibración.',
              style: TextStyle(fontSize: 12, color: context.surface600)),
            const SizedBox(height: Spacing.sm),
            if (telemetry != null) ...[
              Text('Valores actuales:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.surface500)),
              const SizedBox(height: 4),
              _liveFlexRow('Índice', telemetry.flexIndex),
              _liveFlexRow('Medio', telemetry.flexMiddle),
              const SizedBox(height: Spacing.sm),
            ],
            ValueListenableBuilder<int?>(
              valueListenable: _min,
              builder: (_, min, __) {
                final max = _max.value;
                if (min == null && max == null) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withAlpha(12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(children: [
                    const Icon(Icons.check_circle, size: 16, color: AppColors.primary500),
                    const SizedBox(width: 6),
                    Text(
                      min != null && max != null
                          ? 'Mín: $min  Máx: $max'
                          : min != null
                              ? 'Mínimo capturado: $min'
                              : 'Máximo capturado: $max',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary600),
                    ),
                  ]),
                );
              },
            ),
            const SizedBox(height: Spacing.sm),
            Row(children: [
              Expanded(
                child: GantiaButton(
                  label: 'Capturar Mín',
                  icon: Icons.arrow_downward,
                  variant: GantiaButtonVariant.default_,
                  onPressed: telemetry == null ? null
                      : () { _min.value = telemetry.flexIndex; _sensor.value = 'flex_index'; },
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: GantiaButton(
                  label: 'Capturar Máx',
                  icon: Icons.arrow_upward,
                  variant: GantiaButtonVariant.default_,
                  onPressed: telemetry == null ? null
                      : () { _max.value = telemetry.flexIndex; _sensor.value = 'flex_index'; },
                ),
              ),
            ]),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar', style: TextStyle(color: context.surface500))),
        ValueListenableBuilder<int?>(
          valueListenable: _min,
          builder: (_, min, __) {
            final max = _max.value;
            return GantiaButton(
              label: 'Guardar',
              variant: GantiaButtonVariant.primary,
              onPressed: min == null || max == null ? null : () async {
                Navigator.of(context).pop();
                await ref.read(calibrationServiceProvider).update(
                  _sensor.value!,
                  minValue: min!.toDouble(),
                  maxValue: max!.toDouble(),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _liveFlexRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(children: [
        Text('$label: ', style: TextStyle(fontSize: 12, color: context.surface600)),
        Text('$value',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary500)),
      ]),
    );
  }
}
