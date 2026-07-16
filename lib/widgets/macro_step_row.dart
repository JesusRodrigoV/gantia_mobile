import 'package:flutter/material.dart';
import '../models/gesture_config_model.dart';
import '../models/action_message.dart';
import 'macro_step_utils.dart';
import 'macro_step_value_field.dart';

class MacroStepRow extends StatelessWidget {
  final int index;
  final MacroStep step;
  final int totalSteps;
  final ValueNotifier<List<MacroStep>> steps;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onRemove;

  const MacroStepRow({
    super.key,
    required this.index,
    required this.step,
    required this.totalSteps,
    required this.steps,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onRemove,
  });

  void _updateAction(String action) {
    final current = List<MacroStep>.from(steps.value);
    current[index] = MacroStep(action: action, value: current[index].value);
    steps.value = current;
  }

  @override
  Widget build(BuildContext context) {
    final items = sequenceActions.contains(step.action)
        ? sequenceActions
        : [step.action, ...sequenceActions];
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('Paso ${index + 1}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant)),
              const Spacer(),
              if (totalSteps > 1) ...[
                if (index > 0) smallIconButton(Icons.keyboard_arrow_up, 'Mover arriba', onMoveUp),
                if (index < totalSteps - 1) smallIconButton(Icons.keyboard_arrow_down, 'Mover abajo', onMoveDown),
                if (totalSteps > 1)
                  smallIconButton(Icons.delete_outline, 'Eliminar paso', onRemove, color: Colors.red.shade400),
              ],
            ]),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: step.action,
              isExpanded: true,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                labelText: 'Acción',
                labelStyle: TextStyle(fontSize: 11),
              ),
              style: const TextStyle(fontSize: 12),
              items: items.map((a) => DropdownMenuItem(
                value: a, child: Text(getActionLabel(a), style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: (v) { if (v != null) _updateAction(v); },
            ),
            const SizedBox(height: 6),
            MacroStepValueField(index: index, steps: steps),
          ],
        ),
      ),
    );
  }
}
