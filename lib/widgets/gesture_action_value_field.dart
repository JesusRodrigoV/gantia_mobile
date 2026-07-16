import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gesture_config_model.dart';
import '../providers.dart';
import '../theme/context_extensions.dart';
import 'macro_step_editor.dart';

class GestureActionValueField extends ConsumerStatefulWidget {
  final ValueNotifier<String> actionKeyCtrl;
  final TextEditingController actionValueCtrl;
  final ValueNotifier<List<MacroStep>> macroStepsNotifier;
  final ValueNotifier<int> macroRepeatNotifier;

  const GestureActionValueField({
    super.key,
    required this.actionKeyCtrl,
    required this.actionValueCtrl,
    required this.macroStepsNotifier,
    required this.macroRepeatNotifier,
  });

  @override
  ConsumerState<GestureActionValueField> createState() => _GestureActionValueFieldState();
}

class _GestureActionValueFieldState extends ConsumerState<GestureActionValueField> {
  final _macroIsRecordingNotifier = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: widget.actionKeyCtrl,
      builder: (context, actionKey, _) {
        if (actionKey == 'sequence') {
          return MacroStepEditor(
            steps: widget.macroStepsNotifier,
            repeat: widget.macroRepeatNotifier,
            isRecording: _macroIsRecordingNotifier,
            onToggleRecording: _toggleRecording,
          );
        }
        return TextField(
          controller: widget.actionValueCtrl,
          decoration: InputDecoration(
            labelText: 'Valor (opcional)',
            labelStyle: TextStyle(color: context.surface500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.surface200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.surface200),
            ),
            filled: true,
            fillColor: context.surface0,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          style: TextStyle(fontSize: 14, color: context.surface700),
        );
      },
    );
  }

  void _toggleRecording() {
    final recordingService = ref.read(recordingServiceProvider);
    if (_macroIsRecordingNotifier.value) {
      _macroIsRecordingNotifier.value = false;
      final captured = recordingService.stop();
      if (captured.isNotEmpty) {
        widget.macroStepsNotifier.value = [...widget.macroStepsNotifier.value, ...captured];
      }
    } else {
      recordingService.start();
      _macroIsRecordingNotifier.value = true;
    }
  }

  @override
  void dispose() {
    _macroIsRecordingNotifier.dispose();
    super.dispose();
  }
}
