import 'package:flutter/material.dart';
import '../models/gesture_config_model.dart';

List<MacroStep> parsePipeToSteps(String? value) {
  if (value == null || value.isEmpty) return [];
  return value.split('|').map((part) {
    part = part.trim();
    if (part.isEmpty) return null;
    final colonIndex = part.indexOf(':');
    if (colonIndex == -1) return MacroStep(action: part.trim());
    final action = part.substring(0, colonIndex).trim();
    final val = part.substring(colonIndex + 1).trim();
    return MacroStep(action: action, value: val.isNotEmpty ? val : null);
  }).whereType<MacroStep>().toList();
}

const sequenceActions = [
  'hotkey', 'delay', 'left_click', 'right_click',
  'scroll_up', 'scroll_down', 'type_string',
  'open_browser', 'open_url', 'open_app',
  'mute', 'volume_up', 'volume_down', 'play_pause', 'next', 'prev',
];

bool needsValue(String action) {
  return const {
    'hotkey', 'delay', 'type_string', 'open_url', 'open_app',
    'scroll_up', 'scroll_down', 'volume_up', 'volume_down',
  }.contains(action);
}

String valueLabel(String action) {
  switch (action) {
    case 'hotkey': return 'Teclas (ej: ctrl,c)';
    case 'delay': return 'Segundos (ej: 0.5)';
    case 'type_string': return 'Texto a escribir';
    case 'open_url': return 'URL';
    case 'open_app': return 'App';
    case 'scroll_up': case 'scroll_down': return 'Cantidad';
    case 'volume_up': case 'volume_down': return 'Incremento';
    default: return 'Valor';
  }
}

Widget smallIconButton(IconData icon, String tooltip, VoidCallback onPressed, {Color? color}) {
  return Tooltip(
    message: tooltip,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    ),
  );
}
