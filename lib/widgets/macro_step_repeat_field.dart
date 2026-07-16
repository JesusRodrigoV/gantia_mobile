import 'package:flutter/material.dart';

class MacroStepRepeatField extends StatefulWidget {
  final ValueNotifier<int> repeat;
  const MacroStepRepeatField({super.key, required this.repeat});

  @override
  State<MacroStepRepeatField> createState() => _MacroStepRepeatFieldState();
}

class _MacroStepRepeatFieldState extends State<MacroStepRepeatField> {
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
    if (current != expected) _controller.text = expected;
  }

  @override
  void dispose() {
    widget.repeat.removeListener(_syncFromNotifier);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Text('Repetir:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
        const SizedBox(width: 8),
        SizedBox(
          width: 72,
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
            ),
            style: const TextStyle(fontSize: 13),
            onChanged: (v) {
              final parsed = int.tryParse(v);
              if (parsed != null && parsed > 0) widget.repeat.value = parsed;
            },
          ),
        ),
        const SizedBox(width: 8),
        Text('vez(es)', style: TextStyle(fontSize: 12, color: fg)),
      ],
    );
  }
}
