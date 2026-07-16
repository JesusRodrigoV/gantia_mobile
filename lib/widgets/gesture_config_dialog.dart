import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/action_message.dart';
import '../models/gesture_config_model.dart';
import '../providers.dart';
import 'macro_step_utils.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../widgets/gantia_button.dart';
import 'gesture_action_value_field.dart';
import 'gesture_composite_editor.dart';
import 'gesture_config_form_fields.dart';
import 'gesture_hotkey_editor.dart';

Map<String, dynamic> _buildSavePayload(
  String movement, String orientation, int indexState, int middleState,
  String actionKey, String? actionValue, String context,
  String compositeActionKey,
  Map<String, dynamic> step1, Map<String, dynamic> step2,
  List<MacroStep> macroSteps, int macroRepeat,
) {
  if (movement == 'COMPOSITE') {
    return {
      'movement': 'COMPOSITE', 'orientation': 'ANY', 'index_state': 0, 'middle_state': 0,
      'action_key': compositeActionKey,
      'action_value': jsonEncode([step1, step2]),
      'context': context,
    };
  }
  return {
    'movement': movement, 'orientation': orientation,
    'index_state': indexState, 'middle_state': middleState,
    'action_key': actionKey,
    'action_value': actionKey == 'sequence'
        ? jsonEncode(MacroData(steps: macroSteps, repeat: macroRepeat).toJson())
        : (actionValue != null && actionValue.isNotEmpty ? actionValue : null),
    'context': context,
  };
}

Future<void> showGestureConfigDialog(
  BuildContext context,
  WidgetRef ref, {
  GestureConfig? existing,
}) async {
  final isEditing = existing != null;
  final movementCtrl = ValueNotifier<String>(existing?.movement ?? 'NONE');
  final orientationCtrl = ValueNotifier<String>(existing?.orientation ?? 'ANY');
  final indexStateCtrl = ValueNotifier<int>(existing?.indexState ?? 0);
  final middleStateCtrl = ValueNotifier<int>(existing?.middleState ?? 0);
  final actionKeyCtrl = ValueNotifier<String>(existing?.actionKey ?? actions.first);
  final actionValueCtrl = TextEditingController(text: existing?.actionValue ?? '');
  final contextCtrl = ValueNotifier<String>(existing?.context ?? 'GLOBAL');

  final compositeStep1Movement = ValueNotifier<String>('SWIPE_RIGHT');
  final compositeStep1Index = ValueNotifier<int>(2);
  final compositeStep1Middle = ValueNotifier<int>(2);
  final compositeStep2Movement = ValueNotifier<String>('TWIST');
  final compositeStep2Index = ValueNotifier<int>(2);
  final compositeStep2Middle = ValueNotifier<int>(2);
  final compositeActionKeyCtrl = ValueNotifier<String>('next_track');

  final macroStepsNotifier = ValueNotifier<List<MacroStep>>([]);
  final macroRepeatNotifier = ValueNotifier<int>(1);

  if (existing?.actionKey == 'sequence' && existing?.actionValue != null) {
    final rawValue = existing!.actionValue!;
    try {
      final parsed = jsonDecode(rawValue);
      if (parsed is Map<String, dynamic>) {
        final macroData = MacroData.fromJson(parsed);
        macroStepsNotifier.value = macroData.steps;
        macroRepeatNotifier.value = macroData.repeat;
      } else if (parsed is List) {
        macroStepsNotifier.value = parsed
            .map((e) => MacroStep.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      macroStepsNotifier.value = parsePipeToSteps(rawValue);
    }
  }

  if (existing?.movement == 'COMPOSITE' && existing?.actionValue != null) {
    try {
      final steps = jsonDecode(existing!.actionValue!) as List;
      if (steps.length >= 2) {
        compositeStep1Movement.value = (steps[0]['movement'] as String?) ?? 'SWIPE_RIGHT';
        compositeStep1Index.value = (steps[0]['index_state'] as num?)?.toInt() ?? 2;
        compositeStep1Middle.value = (steps[0]['middle_state'] as num?)?.toInt() ?? 2;
        compositeStep2Movement.value = (steps[1]['movement'] as String?) ?? 'TWIST';
        compositeStep2Index.value = (steps[1]['index_state'] as num?)?.toInt() ?? 2;
        compositeStep2Middle.value = (steps[1]['middle_state'] as num?)?.toInt() ?? 2;
      }
    } catch (_) {}
    compositeActionKeyCtrl.value = existing!.actionKey;
  }

  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: context.surface0,
      title: Text(isEditing ? 'Editar Gesto' : 'Nuevo Gesto',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.surface800)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureConfigFormFields.buildDropdown(
              context: context, label: 'Movimiento', value: movementCtrl,
              items: movements, labelFn: getMovementLabel),
            const SizedBox(height: Spacing.sm),
            ValueListenableBuilder<String>(
              valueListenable: movementCtrl,
              builder: (context, movement, _) {
                if (movement == 'COMPOSITE') {
                  return GestureCompositeEditor(
                    step1Movement: compositeStep1Movement, step1Index: compositeStep1Index,
                    step1Middle: compositeStep1Middle, step2Movement: compositeStep2Movement,
                    step2Index: compositeStep2Index, step2Middle: compositeStep2Middle,
                    compositeActionKey: compositeActionKeyCtrl,
                  );
                }
                return Column(children: [
                  GestureConfigFormFields.buildDropdown(
                    context: context, label: 'Orientación', value: orientationCtrl,
                    items: orientations, labelFn: getOrientationLabel),
                  const SizedBox(height: Spacing.sm),
                  GestureConfigFormFields.buildIntDropdown(
                    context: context, label: 'Estado Índice', value: indexStateCtrl,
                    items: flexStates, labelFn: getFlexStateLabel),
                  const SizedBox(height: Spacing.sm),
                  GestureConfigFormFields.buildIntDropdown(
                    context: context, label: 'Estado Medio', value: middleStateCtrl,
                    items: flexStates, labelFn: getFlexStateLabel),
                  const SizedBox(height: Spacing.sm),
                  GestureConfigFormFields.buildDropdown(
                    context: context, label: 'Acción', value: actionKeyCtrl,
                    items: actions, labelFn: getActionLabel),
                  if (actionKeyCtrl.value == 'hotkey')
                    GestureHotkeyEditor(controller: actionValueCtrl)
                  else
                    GestureActionValueField(
                      actionKeyCtrl: actionKeyCtrl, actionValueCtrl: actionValueCtrl,
                      macroStepsNotifier: macroStepsNotifier,
                      macroRepeatNotifier: macroRepeatNotifier,
                    ),
                ]);
              },
            ),
            const SizedBox(height: Spacing.sm),
            GestureConfigFormFields.buildDropdown(
              context: context, label: 'Contexto', value: contextCtrl,
              items: contexts, labelFn: getContextLabel),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(),
          child: Text('Cancelar', style: TextStyle(color: context.surface500))),
        GantiaButton(
          label: isEditing ? 'Guardar' : 'Crear',
          variant: GantiaButtonVariant.primary,
          onPressed: () async {
            Navigator.of(ctx).pop();
            final payload = _buildSavePayload(
              movementCtrl.value, orientationCtrl.value,
              indexStateCtrl.value, middleStateCtrl.value,
              actionKeyCtrl.value, actionValueCtrl.text, contextCtrl.value,
              compositeActionKeyCtrl.value,
              {
                'movement': compositeStep1Movement.value,
                'index_state': compositeStep1Index.value,
                'middle_state': compositeStep1Middle.value,
                'orientation': 'ANY',
              },
              {
                'movement': compositeStep2Movement.value,
                'index_state': compositeStep2Index.value,
                'middle_state': compositeStep2Middle.value,
                'orientation': 'ANY',
              },
              macroStepsNotifier.value, macroRepeatNotifier.value,
            );

            if (isEditing) {
              await ref.read(gestureConfigServiceProvider).update(existing.id, payload);
            } else {
              await ref.read(gestureConfigServiceProvider).create(payload);
            }
          },
        ),
      ],
    ),
  );
}
