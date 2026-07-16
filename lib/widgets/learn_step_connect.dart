import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import 'gantia_button.dart';
import 'learn_step_header.dart';

class LearnStepConnect extends StatelessWidget {
  final bool hasTelemetry;
  final String telemetryInfo;
  final bool canStart;
  final VoidCallback? onStart;
  final VoidCallback onCancel;

  const LearnStepConnect({
    super.key,
    required this.hasTelemetry,
    required this.telemetryInfo,
    required this.canStart,
    this.onStart,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LearnStepHeader(step: 'Paso 1/4', title: 'Conectá el guante'),
        const SizedBox(height: Spacing.sm),
        if (hasTelemetry)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary500.withAlpha(12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              const Icon(Icons.check_circle, size: 18, color: AppColors.primary500),
              const SizedBox(width: 6),
              Text(telemetryInfo,
                style: TextStyle(fontSize: 12, color: AppColors.primary600)),
            ]),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: context.surface100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              Icon(Icons.bluetooth_disabled, size: 18, color: context.surface400),
              const SizedBox(width: 6),
              Text('Esperando conexión del guante...',
                style: TextStyle(fontSize: 12, color: context.surface500)),
            ]),
          ),
        if (canStart) ...[
          const SizedBox(height: Spacing.sm),
          GantiaButton(
            label: 'Comenzar Aprendizaje',
            icon: Icons.fingerprint,
            variant: GantiaButtonVariant.primary,
            onPressed: onStart,
          ),
        ],
        const SizedBox(height: Spacing.sm),
        GantiaButton(label: 'Cancelar', variant: GantiaButtonVariant.danger, onPressed: onCancel),
      ],
    );
  }
}
