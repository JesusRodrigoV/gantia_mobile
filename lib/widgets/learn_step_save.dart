import 'package:flutter/material.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import 'gantia_button.dart';
import 'learn_step_header.dart';

class LearnStepSave extends StatelessWidget {
  final String? selectedAction;
  final List<DropdownMenuItem<String>> actionItems;
  final ValueChanged<String?> onActionChanged;
  final VoidCallback? onSave;
  final VoidCallback onCancel;

  const LearnStepSave({
    super.key,
    required this.selectedAction,
    required this.actionItems,
    required this.onActionChanged,
    this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LearnStepHeader(step: 'Paso 4/4', title: 'Guardar Gesto'),
        const SizedBox(height: Spacing.sm),
        Text('Elegí la acción para este gesto:',
          style: TextStyle(fontSize: 12, color: context.surface500)),
        const SizedBox(height: Spacing.sm),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.surface50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.surface200),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedAction,
              isExpanded: true,
              items: actionItems,
              onChanged: onActionChanged,
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Row(children: [
          Expanded(
            child: GantiaButton(
              label: 'Guardar Gesto',
              icon: Icons.save,
              variant: GantiaButtonVariant.primary,
              onPressed: selectedAction == null ? null : onSave,
            ),
          ),
        ]),
        const SizedBox(height: Spacing.sm),
        GantiaButton(label: 'Cancelar', variant: GantiaButtonVariant.danger, onPressed: onCancel),
      ],
    );
  }
}
