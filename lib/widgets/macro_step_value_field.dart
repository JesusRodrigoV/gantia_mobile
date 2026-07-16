import 'package:flutter/material.dart';
import '../models/gesture_config_model.dart';
import 'macro_step_utils.dart';

class MacroStepValueField extends StatefulWidget {
  final int index;
  final ValueNotifier<List<MacroStep>> steps;

  const MacroStepValueField({
    super.key,
    required this.index,
    required this.steps,
  });

  @override
  State<MacroStepValueField> createState() => _MacroStepValueFieldState();
}

class _MacroStepValueFieldState extends State<MacroStepValueField> {
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
    if (!needsValue(step.action)) {
      if (mounted) setState(() {});
      return;
    }
    final current = _controller.text;
    final expected = step.value ?? '';
    if (current != expected) _controller.text = expected;
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
    if (!needsValue(step.action)) return const SizedBox.shrink();
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
        labelText: valueLabel(step.action),
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
