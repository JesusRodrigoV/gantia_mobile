import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import 'gantia_button.dart';
import 'learn_step_header.dart';

class LearnStepSample extends StatelessWidget {
  final int samplesCollected;
  final String? error;
  final VoidCallback? onCapture;
  final VoidCallback onCancel;

  const LearnStepSample({
    super.key,
    required this.samplesCollected,
    this.error,
    this.onCapture,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LearnStepHeader(step: 'Paso 2/4',
          title: 'Realizá el gesto $samplesCollected/3 veces'),
        const SizedBox(height: Spacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Spacing.sm),
          decoration: BoxDecoration(
            color: context.surface100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            for (int i = 0; i < 3; i++) ...[
              Icon(i < samplesCollected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 20,
                color: i < samplesCollected ? AppColors.primary500 : context.surface400),
              if (i < 2) const SizedBox(width: 8),
            ],
            const Spacer(),
            Text('$samplesCollected/3',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.surface600)),
          ]),
        ),
        const SizedBox(height: Spacing.sm),
        if (samplesCollected < 3)
          GantiaButton(
            label: samplesCollected == 0
                ? 'Capturar Muestra 1'
                : samplesCollected == 1
                    ? 'Capturar Muestra 2'
                    : 'Capturar Muestra 3',
            icon: Icons.touch_app,
            variant: GantiaButtonVariant.primary,
            onPressed: onCapture,
          ),
        if (error != null) ...[
          const SizedBox(height: Spacing.xs),
          Text(error!, style: TextStyle(fontSize: 12, color: AppColors.red500)),
        ],
        const SizedBox(height: Spacing.sm),
        GantiaButton(label: 'Cancelar', variant: GantiaButtonVariant.danger, onPressed: onCancel),
      ],
    );
  }
}
