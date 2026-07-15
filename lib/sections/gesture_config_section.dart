import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/action_message.dart';
import '../models/gesture_config_model.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../widgets/gantia_button.dart';
import '../widgets/macro_step_editor.dart';
import '../widgets/neuromorphic_card.dart';
import '../widgets/settings_card.dart';
import '../widgets/skeleton_card.dart';

class GestureConfigSection extends ConsumerStatefulWidget {
  const GestureConfigSection({super.key});

  @override
  ConsumerState<GestureConfigSection> createState() =>
      _GestureConfigSectionState();
}

class _GestureConfigSectionState extends ConsumerState<GestureConfigSection> {
  String _selectedContext = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gestureConfigServiceProvider).getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(gestureConfigServiceProvider);

    return SettingsCard(
      icon: Icons.gesture,
      title: 'Gestos Configurados',
      description: 'Acciones asignadas a cada gesto manual',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContextFilter(),
          const SizedBox(height: Spacing.sm),
          if (service.isLoading && service.configs.isEmpty)
            const SkeletonCard(height: 100, lines: 2)
          else if (service.error != null)
            _buildErrorState(service.error!, () => service.getAll())
          else
            _buildConfigList(service),
        ],
      ),
    );
  }

  Widget _buildContextFilter() {
    final allContexts = ['ALL', ...contexts];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allContexts.length,
        separatorBuilder: (_, _) => const SizedBox(width: Spacing.xs),
        itemBuilder: (context, i) {
          final c = allContexts[i];
          final selected = _selectedContext == c;
          return ChoiceChip(
            label: Text(c == 'ALL' ? 'Todas' : getContextLabel(c)),
            selected: selected,
            onSelected: (_) => setState(() => _selectedContext = c),
            selectedColor: AppColors.primary500,
            labelStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : context.surface600,
            ),
            backgroundColor: context.surface0,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }

  Widget _buildConfigList(GestureConfigService service) {
    final filtered = _selectedContext == 'ALL'
        ? service.configs
        : service.configs
            .where((c) => c.context == _selectedContext)
            .toList();

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
        child: Center(
          child: Text(
            _selectedContext == 'ALL'
                ? 'No hay gestos configurados'
                : 'No hay gestos para este contexto',
            style: TextStyle(fontSize: 13, color: context.surface500),
          ),
        ),
      );
    }

    return Column(
      children: [
        ...filtered.map((config) => _buildConfigRow(config)),
        const SizedBox(height: Spacing.sm),
        GantiaButton(
          label: 'Agregar Gesto',
          icon: Icons.add,
          variant: GantiaButtonVariant.primary,
          onPressed: () => _showCreateEditDialog(),
        ),
      ],
    );
  }

  Widget _buildConfigRow(GestureConfig config) {
    return NeuromorphicCard(
      showAccentLine: false,
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.movement == 'COMPOSITE'
                      ? 'Compuesto: ${config.actionKey}'
                      : '${getMovementLabel(config.movement)} / ${getOrientationLabel(config.orientation)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.surface700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Índice: ${getFlexStateLabel(config.indexState)}   '
                  'Medio: ${getFlexStateLabel(config.middleState)}',
                  style: TextStyle(fontSize: 11, color: context.surface500),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary500.withAlpha(20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        config.movement == 'COMPOSITE'
                            ? 'COMPUESTO'
                            : getActionLabel(config.actionKey),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: config.movement == 'COMPOSITE'
                              ? AppColors.amber600
                              : AppColors.primary600,
                        ),
                      ),
                    ),
                    if (config.actionValue != null &&
                        config.actionValue!.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Text(
                        ': ${config.actionValue}',
                        style: TextStyle(
                          fontSize: 10,
                          color: context.surface500,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      getContextLabel(config.context),
                      style: TextStyle(
                        fontSize: 10,
                        color: context.surface400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.xs),
          _buildRowActionButton(
            Icons.edit,
            'Editar',
            AppColors.primary500,
            () => _showCreateEditDialog(config),
          ),
          const SizedBox(width: 4),
          _buildRowActionButton(
            Icons.delete,
            'Borrar',
            AppColors.red500,
            () => _confirmDelete(config),
          ),
        ],
      ),
    );
  }

  Widget _buildRowActionButton(
    IconData icon,
    String tooltip,
    Color color,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  void _showCreateEditDialog([GestureConfig? existing]) {
    final isEditing = existing != null;
    final movementCtrl = ValueNotifier<String>(existing?.movement ?? 'NONE');
    final orientationCtrl =
        ValueNotifier<String>(existing?.orientation ?? 'ANY');
    final indexStateCtrl = ValueNotifier<int>(existing?.indexState ?? 0);
    final middleStateCtrl = ValueNotifier<int>(existing?.middleState ?? 0);
    final actionKeyCtrl =
        ValueNotifier<String>(existing?.actionKey ?? actions.first);
    final actionValueCtrl =
        TextEditingController(text: existing?.actionValue ?? '');
    final contextCtrl =
        ValueNotifier<String>(existing?.context ?? 'GLOBAL');

    final compositeStep1Movement = ValueNotifier<String>('SWIPE_RIGHT');
    final compositeStep1Index = ValueNotifier<int>(2);
    final compositeStep1Middle = ValueNotifier<int>(2);
    final compositeStep2Movement = ValueNotifier<String>('TWIST');
    final compositeStep2Index = ValueNotifier<int>(2);
    final compositeStep2Middle = ValueNotifier<int>(2);
    final compositeActionKeyCtrl = ValueNotifier<String>('next_track');

    final macroStepsNotifier = ValueNotifier<List<MacroStep>>([]);
    final macroRepeatNotifier = ValueNotifier<int>(1);
    final macroIsRecordingNotifier = ValueNotifier<bool>(false);
    final recordingService = ref.read(recordingServiceProvider);

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
          compositeStep1Movement.value =
              (steps[0]['movement'] as String?) ?? 'SWIPE_RIGHT';
          compositeStep1Index.value =
              (steps[0]['index_state'] as num?)?.toInt() ?? 2;
          compositeStep1Middle.value =
              (steps[0]['middle_state'] as num?)?.toInt() ?? 2;
          compositeStep2Movement.value =
              (steps[1]['movement'] as String?) ?? 'TWIST';
          compositeStep2Index.value =
              (steps[1]['index_state'] as num?)?.toInt() ?? 2;
          compositeStep2Middle.value =
              (steps[1]['middle_state'] as num?)?.toInt() ?? 2;
        }
      } catch (_) {}
      compositeActionKeyCtrl.value = existing!.actionKey;
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surface0,
        title: Text(
          isEditing ? 'Editar Gesto' : 'Nuevo Gesto',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: context.surface800,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDropdown(
                label: 'Movimiento',
                value: movementCtrl,
                items: movements,
                labelFn: getMovementLabel,
              ),
              const SizedBox(height: Spacing.sm),
              ValueListenableBuilder<String>(
                valueListenable: movementCtrl,
                builder: (context, movement, _) {
                  if (movement == 'COMPOSITE') {
                    return _buildCompositeEditor(
                      step1Movement: compositeStep1Movement,
                      step1Index: compositeStep1Index,
                      step1Middle: compositeStep1Middle,
                      step2Movement: compositeStep2Movement,
                      step2Index: compositeStep2Index,
                      step2Middle: compositeStep2Middle,
                      compositeActionKey: compositeActionKeyCtrl,
                    );
                  }
                  return Column(
                    children: [
                      _buildDropdown(
                        label: 'Orientación',
                        value: orientationCtrl,
                        items: orientations,
                        labelFn: getOrientationLabel,
                      ),
                      const SizedBox(height: Spacing.sm),
                      _buildIntDropdown(
                        label: 'Estado Índice',
                        value: indexStateCtrl,
                        items: flexStates,
                        labelFn: getFlexStateLabel,
                      ),
                      const SizedBox(height: Spacing.sm),
                      _buildIntDropdown(
                        label: 'Estado Medio',
                        value: middleStateCtrl,
                        items: flexStates,
                        labelFn: getFlexStateLabel,
                      ),
                      const SizedBox(height: Spacing.sm),
                      _buildDropdown(
                        label: 'Acción',
                        value: actionKeyCtrl,
                        items: actions,
                        labelFn: getActionLabel,
                      ),
                      const SizedBox(height: Spacing.sm),
                      if (actionKeyCtrl.value == 'hotkey') ...[
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: actionValueCtrl,
                          builder: (context, val, _) {
                            final keys = val.text.isNotEmpty
                                ? val.text.split(',')
                                : <String>[];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (keys.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: keys.map((k) => Chip(
                                        label: Text(
                                          k.trim(),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary600,
                                          ),
                                        ),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                        backgroundColor:
                                            AppColors.primary500.withAlpha(20),
                                        side: BorderSide.none,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      )).toList(),
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      'Teclas separadas por coma',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: context.surface400,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                TextField(
                                  controller: actionValueCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'Combinación (separada por coma)',
                                    labelStyle:
                                        TextStyle(color: context.surface500),
                                    hintText: 'ctrl,shift,esc',
                                    hintStyle:
                                        TextStyle(color: context.surface400),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: context.surface200),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: context.surface200),
                                    ),
                                    filled: true,
                                    fillColor: context.surface0,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.surface700,
                                  ),
                                ),
                                const SizedBox(height: Spacing.sm),
                                Text(
                                  'Predefinidos:',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: context.surface500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: [
                                    _hotkeyPresetChip(
                                      'Ctrl+C', 'ctrl,c', actionValueCtrl),
                                    _hotkeyPresetChip(
                                      'Ctrl+V', 'ctrl,v', actionValueCtrl),
                                    _hotkeyPresetChip(
                                      'Ctrl+X', 'ctrl,x', actionValueCtrl),
                                    _hotkeyPresetChip(
                                      'Ctrl+Z', 'ctrl,z', actionValueCtrl),
                                    _hotkeyPresetChip(
                                      'Win+D', 'win,d', actionValueCtrl),
                                    _hotkeyPresetChip(
                                      'Alt+Tab', 'alt,tab', actionValueCtrl),
                                    _hotkeyPresetChip(
                                      'Win+E', 'win,e', actionValueCtrl),
                                    _hotkeyPresetChip('Ctrl+Shift+Esc',
                                        'ctrl,shift,esc', actionValueCtrl),
                                    _hotkeyPresetChip(
                                      'F5', 'f5', actionValueCtrl),
                                    _hotkeyPresetChip(
                                      'F11', 'f11', actionValueCtrl),
                                    _hotkeyPresetChip(
                                      'Win+R', 'win,r', actionValueCtrl),
                                    _hotkeyPresetChip('Ctrl+Alt+Del',
                                        'ctrl,alt,delete', actionValueCtrl),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ] else ...[
                        ValueListenableBuilder<String>(
                          valueListenable: actionKeyCtrl,
                          builder: (context, actionKey, _) {
                            if (actionKey == 'sequence') {
                              return MacroStepEditor(
                                steps: macroStepsNotifier,
                                repeat: macroRepeatNotifier,
                                isRecording: macroIsRecordingNotifier,
                                onToggleRecording: () {
                                  if (macroIsRecordingNotifier.value) {
                                    macroIsRecordingNotifier.value = false;
                                    final captured =
                                        recordingService.stop();
                                    if (captured.isNotEmpty) {
                                      macroStepsNotifier.value = [
                                        ...macroStepsNotifier.value,
                                        ...captured,
                                      ];
                                    }
                                  } else {
                                    recordingService.start();
                                    macroIsRecordingNotifier.value = true;
                                  }
                                },
                              );
                            }
                            return TextField(
                              controller: actionValueCtrl,
                              decoration: InputDecoration(
                                labelText: 'Valor (opcional)',
                                labelStyle:
                                    TextStyle(color: context.surface500),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: context.surface200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: context.surface200),
                                ),
                                filled: true,
                                fillColor: context.surface0,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              style: TextStyle(
                                  fontSize: 14, color: context.surface700),
                            );
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: Spacing.sm),
              _buildDropdown(
                label: 'Contexto',
                value: contextCtrl,
                items: contexts,
                labelFn: getContextLabel,
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
            label: isEditing ? 'Guardar' : 'Crear',
            variant: GantiaButtonVariant.primary,
            onPressed: () async {
              Navigator.of(ctx).pop();
              bool isComposite = movementCtrl.value == 'COMPOSITE';
              final data = isComposite
                  ? <String, dynamic>{
                      'movement': 'COMPOSITE',
                      'orientation': 'ANY',
                      'index_state': 0,
                      'middle_state': 0,
                      'action_key': compositeActionKeyCtrl.value,
                      'action_value': jsonEncode([
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
                      ]),
                      'context': contextCtrl.value,
                    }
                  : <String, dynamic>{
                      'movement': movementCtrl.value,
                      'orientation': orientationCtrl.value,
                      'index_state': indexStateCtrl.value,
                      'middle_state': middleStateCtrl.value,
                      'action_key': actionKeyCtrl.value,
                      'action_value': actionKeyCtrl.value == 'sequence'
                          ? jsonEncode(MacroData(
                                  steps: macroStepsNotifier.value,
                                  repeat: macroRepeatNotifier.value)
                              .toJson())
                          : actionValueCtrl.text.isNotEmpty
                              ? actionValueCtrl.text
                              : null,
                      'context': contextCtrl.value,
                    };

              if (isEditing) {
                await ref
                    .read(gestureConfigServiceProvider)
                    .update(existing.id, data);
              } else {
                await ref
                    .read(gestureConfigServiceProvider)
                    .create(data);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required ValueNotifier<String> value,
    required List<String> items,
    required String Function(String) labelFn,
  }) {
    return ValueListenableBuilder<String>(
      valueListenable: value,
      builder: (context, val, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.surface500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: context.surface50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.surface200),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: val,
                  isExpanded: true,
                  items: items
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              labelFn(item),
                              style: TextStyle(
                                fontSize: 13,
                                color: context.surface700,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) value.value = v;
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIntDropdown({
    required String label,
    required ValueNotifier<int> value,
    required List<int> items,
    required String Function(int) labelFn,
  }) {
    return ValueListenableBuilder<int>(
      valueListenable: value,
      builder: (context, val, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.surface500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: context.surface50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.surface200),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: val,
                  isExpanded: true,
                  items: items
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              labelFn(item),
                              style: TextStyle(
                                fontSize: 13,
                                color: context.surface700,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) value.value = v;
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompositeEditor({
    required ValueNotifier<String> step1Movement,
    required ValueNotifier<int> step1Index,
    required ValueNotifier<int> step1Middle,
    required ValueNotifier<String> step2Movement,
    required ValueNotifier<int> step2Index,
    required ValueNotifier<int> step2Middle,
    required ValueNotifier<String> compositeActionKey,
  }) {
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
        _buildDropdown(
          label: 'Movimiento',
          value: step1Movement,
          items: movements.where((m) => m != 'COMPOSITE').toList(),
          labelFn: getMovementLabel,
        ),
        const SizedBox(height: Spacing.xs),
        Row(
          children: [
            Expanded(
              child: _buildIntDropdown(
                label: 'Índice',
                value: step1Index,
                items: flexStates,
                labelFn: getFlexStateLabel,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: _buildIntDropdown(
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
        _buildDropdown(
          label: 'Movimiento',
          value: step2Movement,
          items: movements.where((m) => m != 'COMPOSITE').toList(),
          labelFn: getMovementLabel,
        ),
        const SizedBox(height: Spacing.xs),
        Row(
          children: [
            Expanded(
              child: _buildIntDropdown(
                label: 'Índice',
                value: step2Index,
                items: flexStates,
                labelFn: getFlexStateLabel,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: _buildIntDropdown(
                label: 'Medio',
                value: step2Middle,
                items: flexStates,
                labelFn: getFlexStateLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        _buildDropdown(
          label: 'Acción compuesta',
          value: compositeActionKey,
          items: actions,
          labelFn: getActionLabel,
        ),
      ],
    );
  }

  Future<void> _confirmDelete(GestureConfig config) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surface0,
        title: const Text(
          'Eliminar Gesto',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          '¿Eliminar ${getMovementLabel(config.movement)} / '
          '${getOrientationLabel(config.orientation)}?',
          style: TextStyle(color: context.surface600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.red500),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(gestureConfigServiceProvider).delete(config.id);
    }
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.red500, size: 32),
          const SizedBox(height: Spacing.xs),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: context.surface500),
          ),
          const SizedBox(height: Spacing.sm),
          GantiaButton(
            label: 'Reintentar',
            icon: Icons.refresh,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }

  Widget _hotkeyPresetChip(
    String label,
    String value,
    TextEditingController ctrl,
  ) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primary600,
        ),
      ),
      onPressed: () => ctrl.text = value,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      backgroundColor: AppColors.primary500.withAlpha(12),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
