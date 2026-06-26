import 'package:flutter/material.dart';
import '../models/gesture_config_model.dart';
import '../models/action_message.dart';

List<MacroStep> parsePipeToSteps(String? value) {
  if (value == null || value.isEmpty) return [];
  return value.split('|').map((part) {
    part = part.trim();
    if (part.isEmpty) return null;
    final colonIndex = part.indexOf(':');
    if (colonIndex == -1) {
      return MacroStep(action: part.trim());
    }
    final action = part.substring(0, colonIndex).trim();
    final val = part.substring(colonIndex + 1).trim();
    return MacroStep(
      action: action,
      value: val.isNotEmpty ? val : null,
    );
  }).whereType<MacroStep>().toList();
}

const _sequenceActions = [
  'hotkey',
  'delay',
  'left_click',
  'right_click',
  'scroll_up',
  'scroll_down',
  'type_string',
  'open_browser',
  'open_url',
  'open_app',
  'mute',
  'volume_up',
  'volume_down',
  'play_pause',
  'next',
  'prev',
];

class _RepeatField extends StatefulWidget {
  final ValueNotifier<int> repeat;
  const _RepeatField({required this.repeat});

  @override
  State<_RepeatField> createState() => _RepeatFieldState();
}

class _RepeatFieldState extends State<_RepeatField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.repeat.value.toString());
    widget.repeat.addListener(_syncFromNotifier);
  }

  void _syncFromNotifier() {
    final current = _controller.text;
    final expected = widget.repeat.value.toString();
    if (current != expected) {
      _controller.text = expected;
    }
  }

  @override
  void dispose() {
    widget.repeat.removeListener(_syncFromNotifier);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Repetir:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 72,
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            style: const TextStyle(fontSize: 13),
            onChanged: (v) {
              final parsed = int.tryParse(v);
              if (parsed != null && parsed > 0) {
                widget.repeat.value = parsed;
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'vez(es)',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StepValueField extends StatefulWidget {
  final int index;
  final ValueNotifier<List<MacroStep>> steps;

  const _StepValueField({
    required this.index,
    required this.steps,
  });

  @override
  State<_StepValueField> createState() => _StepValueFieldState();
}

class _StepValueFieldState extends State<_StepValueField> {
  late TextEditingController _controller;
  late MacroStep _lastStep;

  @override
  void initState() {
    super.initState();
    _lastStep = widget.steps.value[widget.index];
    _controller = TextEditingController(text: _lastStep.value ?? '');
    widget.steps.addListener(_syncFromNotifier);
  }

  void _syncFromNotifier() {
    if (widget.index >= widget.steps.value.length) return;
    final step = widget.steps.value[widget.index];
    if (!_needsValue(step.action)) {
      if (mounted) setState(() {});
      return;
    }
    final current = _controller.text;
    final expected = step.value ?? '';
    if (current != expected) {
      _controller.text = expected;
    }
    _lastStep = step;
  }

  @override
  void dispose() {
    widget.steps.removeListener(_syncFromNotifier);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index >= widget.steps.value.length) return const SizedBox.shrink();
    final step = widget.steps.value[widget.index];
    if (!_needsValue(step.action)) return const SizedBox.shrink();
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        labelText: _valueLabel(step.action),
        labelStyle: const TextStyle(fontSize: 11),
      ),
      style: const TextStyle(fontSize: 12),
      onChanged: (v) {
        final current = List<MacroStep>.from(widget.steps.value);
        if (widget.index < current.length) {
          current[widget.index] = MacroStep(
            action: current[widget.index].action,
            value: v.isNotEmpty ? v : null,
          );
          widget.steps.value = current;
        }
      },
    );
  }
}

class MacroStepEditor extends StatelessWidget {
  final ValueNotifier<List<MacroStep>> steps;
  final ValueNotifier<int> repeat;
  final ValueNotifier<bool> isRecording;
  final VoidCallback? onToggleRecording;

  const MacroStepEditor({
    super.key,
    required this.steps,
    required this.repeat,
    required this.isRecording,
    this.onToggleRecording,
  });

  static const int maxSteps = 20;

  void _addStep() {
    if (steps.value.length >= maxSteps) return;
    final current = List<MacroStep>.from(steps.value);
    current.add(const MacroStep(action: 'delay'));
    steps.value = current;
  }

  void _removeStep(int index) {
    if (steps.value.length <= 1) return;
    final current = List<MacroStep>.from(steps.value);
    current.removeAt(index);
    steps.value = current;
  }

  void _moveUp(int index) {
    if (index == 0) return;
    final current = List<MacroStep>.from(steps.value);
    final temp = current[index];
    current[index] = current[index - 1];
    current[index - 1] = temp;
    steps.value = current;
  }

  void _moveDown(int index) {
    if (index >= steps.value.length - 1) return;
    final current = List<MacroStep>.from(steps.value);
    final temp = current[index];
    current[index] = current[index + 1];
    current[index + 1] = temp;
    steps.value = current;
  }

  void _updateAction(int index, String action) {
    final current = List<MacroStep>.from(steps.value);
    current[index] = MacroStep(
      action: action,
      value: current[index].value,
    );
    steps.value = current;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: isRecording,
              builder: (context, recording, _) {
                return GantiaSmallButton(
                  icon: recording ? Icons.stop : Icons.fiber_manual_record,
                  label: recording ? 'Detener grabación' : 'Grabar gestos',
                  color: recording ? Colors.red : Colors.grey,
                  onPressed: onToggleRecording,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<List<MacroStep>>(
          valueListenable: steps,
          builder: (context, stepList, _) {
            return Column(
              children: [
                for (int i = 0; i < stepList.length; i++)
                  _buildStepRow(context, i, stepList[i], stepList.length),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: stepList.length >= maxSteps
                        ? null
                        : _addStep,
                    icon: Icon(
                      Icons.add,
                      size: 16,
                      color: stepList.length >= maxSteps
                          ? Colors.grey
                          : Theme.of(context).colorScheme.primary,
                    ),
                    label: Text(
                      stepList.length >= maxSteps
                          ? 'Máximo $maxSteps pasos alcanzado'
                          : 'Agregar paso',
                      style: TextStyle(
                        fontSize: 12,
                        color: stepList.length >= maxSteps
                            ? Colors.grey
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        _RepeatField(repeat: repeat),
      ],
    );
  }

  Widget _buildStepRow(
    BuildContext context,
    int index,
    MacroStep step,
    int totalSteps,
  ) {
    final items = _sequenceActions.contains(step.action)
        ? _sequenceActions
        : [step.action, ..._sequenceActions];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Paso ${index + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (totalSteps > 1) ...[
                  if (index > 0)
                    _smallIconButton(
                      Icons.keyboard_arrow_up,
                      'Mover arriba',
                      () => _moveUp(index),
                    ),
                  if (index < totalSteps - 1)
                    _smallIconButton(
                      Icons.keyboard_arrow_down,
                      'Mover abajo',
                      () => _moveDown(index),
                    ),
                  if (totalSteps > 1)
                    _smallIconButton(
                      Icons.delete_outline,
                      'Eliminar paso',
                      () => _removeStep(index),
                      color: Colors.red.shade400,
                    ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: step.action,
              isExpanded: true,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                labelText: 'Acción',
                labelStyle: const TextStyle(fontSize: 11),
              ),
              style: const TextStyle(fontSize: 12),
              items: items.map((a) {
                return DropdownMenuItem(
                  value: a,
                  child: Text(getActionLabel(a), style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) _updateAction(index, v);
              },
            ),
            const SizedBox(height: 6),
            _StepValueField(index: index, steps: steps),
          ],
        ),
      ),
    );
  }
}

bool _needsValue(String action) {
  return const {
    'hotkey',
    'delay',
    'type_string',
    'open_url',
    'open_app',
    'scroll_up',
    'scroll_down',
    'volume_up',
    'volume_down',
  }.contains(action);
}

String _valueLabel(String action) {
  switch (action) {
    case 'hotkey':
      return 'Teclas (ej: ctrl,c)';
    case 'delay':
      return 'Segundos (ej: 0.5)';
    case 'type_string':
      return 'Texto a escribir';
    case 'open_url':
      return 'URL';
    case 'open_app':
      return 'App';
    case 'scroll_up':
    case 'scroll_down':
      return 'Cantidad';
    case 'volume_up':
    case 'volume_down':
      return 'Incremento';
    default:
      return 'Valor';
  }
}

Widget _smallIconButton(IconData icon, String tooltip, VoidCallback onPressed,
    {Color? color}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 16, color: color),
      ),
    ),
  );
}

class GantiaSmallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const GantiaSmallButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(fontSize: 12, color: color),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
