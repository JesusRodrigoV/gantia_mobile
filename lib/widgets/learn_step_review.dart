import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import 'gantia_button.dart';
import 'learn_step_header.dart';

class AnalysisRow extends StatelessWidget {
  final String label;
  final String value;

  const AnalysisRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: context.surface500)),
        Text(value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.surface700)),
      ],
    );
  }
}

class LearnStepReview extends StatelessWidget {
  final bool hasAnalysis;
  final Widget analysisContent;
  final VoidCallback? onContinue;
  final VoidCallback onCancel;

  const LearnStepReview({
    super.key,
    required this.hasAnalysis,
    required this.analysisContent,
    this.onContinue,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LearnStepHeader(step: 'Paso 3/4', title: 'Analizando gesto'),
        const SizedBox(height: Spacing.sm),
        if (hasAnalysis) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary500.withAlpha(10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: analysisContent,
          ),
          const SizedBox(height: Spacing.sm),
          GantiaButton(
            label: 'Continuar → Elegir Acción',
            icon: Icons.arrow_forward,
            variant: GantiaButtonVariant.primary,
            onPressed: onContinue,
          ),
        ] else ...[
          Text('No se pudo analizar el gesto. Intentá de nuevo.',
            style: TextStyle(fontSize: 12, color: AppColors.red500)),
        ],
        const SizedBox(height: Spacing.sm),
        GantiaButton(label: 'Cancelar', variant: GantiaButtonVariant.danger, onPressed: onCancel),
      ],
    );
  }
}
