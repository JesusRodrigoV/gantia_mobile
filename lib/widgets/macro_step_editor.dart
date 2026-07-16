import 'package:flutter/material.dart';
import '../models/gesture_config_model.dart';
import 'macro_step_repeat_field.dart';
import 'macro_step_row.dart';
import 'macro_step_utils.dart';

const int _maxSteps = 20;

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
      label: Text(label, style: TextStyle(fontSize: 12, color: color)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
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

  void _addStep() {
    if (steps.value.length >= _maxSteps) return;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
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
        ]),
        const SizedBox(height: 8),
        ValueListenableBuilder<List<MacroStep>>(
          valueListenable: steps,
          builder: (context, stepList, _) {
            return Column(children: [
              for (int i = 0; i < stepList.length; i++)
                MacroStepRow(
                  index: i,
                  step: stepList[i],
                  totalSteps: stepList.length,
                  steps: steps,
                  onMoveUp: () => _moveUp(i),
                  onMoveDown: () => _moveDown(i),
                  onRemove: () => _removeStep(i),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: stepList.length >= _maxSteps ? null : _addStep,
                  icon: Icon(Icons.add, size: 16,
                    color: stepList.length >= _maxSteps ? Colors.grey : null),
                  label: Text(
                    stepList.length >= _maxSteps
                        ? 'Máximo $_maxSteps pasos alcanzado'
                        : 'Agregar paso',
                    style: TextStyle(fontSize: 12,
                      color: stepList.length >= _maxSteps ? Colors.grey : null)),
                ),
              ),
            ]);
          },
        ),
        const SizedBox(height: 8),
        MacroStepRepeatField(repeat: repeat),
      ],
    );
  }
}
