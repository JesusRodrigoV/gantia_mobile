import 'package:flutter/material.dart';
import '../models/action_message.dart';
import '../models/gesture_config_model.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import 'gesture_config_form_fields.dart';

class GestureCompositeEditor extends StatelessWidget {
  final ValueNotifier<String> step1Movement;
  final ValueNotifier<int> step1Index;
  final ValueNotifier<int> step1Middle;
  final ValueNotifier<String> step2Movement;
  final ValueNotifier<int> step2Index;
  final ValueNotifier<int> step2Middle;
  final ValueNotifier<String> compositeActionKey;

  const GestureCompositeEditor({
    super.key,
    required this.step1Movement,
    required this.step1Index,
    required this.step1Middle,
    required this.step2Movement,
    required this.step2Index,
    required this.step2Middle,
    required this.compositeActionKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paso 1',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: context.surface600,
          ),
        ),
        const SizedBox(height: 4),
        GestureConfigFormFields.buildDropdown(
          context: context,
          label: 'Movimiento',
          value: step1Movement,
          items: movements.where((m) => m != 'COMPOSITE').toList(),
          labelFn: getMovementLabel,
        ),
        const SizedBox(height: Spacing.xs),
        Row(
          children: [
            Expanded(
              child: GestureConfigFormFields.buildIntDropdown(
                context: context,
                label: 'Índice',
                value: step1Index,
                items: flexStates,
                labelFn: getFlexStateLabel,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: GestureConfigFormFields.buildIntDropdown(
                context: context,
                label: 'Medio',
                value: step1Middle,
                items: flexStates,
                labelFn: getFlexStateLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        Center(
          child: Text(
            '⬇ luego',
            style: TextStyle(fontSize: 12, color: context.surface400),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          'Paso 2',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: context.surface600,
          ),
        ),
        const SizedBox(height: 4),
        GestureConfigFormFields.buildDropdown(
          context: context,
          label: 'Movimiento',
          value: step2Movement,
          items: movements.where((m) => m != 'COMPOSITE').toList(),
          labelFn: getMovementLabel,
        ),
        const SizedBox(height: Spacing.xs),
        Row(
          children: [
            Expanded(
              child: GestureConfigFormFields.buildIntDropdown(
                context: context,
                label: 'Índice',
                value: step2Index,
                items: flexStates,
                labelFn: getFlexStateLabel,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: GestureConfigFormFields.buildIntDropdown(
                context: context,
                label: 'Medio',
                value: step2Middle,
                items: flexStates,
                labelFn: getFlexStateLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        GestureConfigFormFields.buildDropdown(
          context: context,
          label: 'Acción compuesta',
          value: compositeActionKey,
          items: actions,
          labelFn: getActionLabel,
        ),
      ],
    );
  }
}
