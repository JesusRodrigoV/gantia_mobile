export '../utils/gesture_labels.dart';

const List<String> contexts = [
  'GLOBAL',
  'AUDIO',
  'PRESENTATION',
  'WORK',
  'WORKSHOP',
];

const List<String> movements = [
  'NONE',
  'SWIPE_UP',
  'SWIPE_DOWN',
  'SWIPE_LEFT',
  'SWIPE_RIGHT',
  'TWIST',
  'COMPOSITE',
];

const List<String> orientations = [
  'ANY',
  'PALM_UP',
  'PALM_DOWN',
  'UP',
  'DOWN',
  'NEUTRAL',
];

const List<int> flexStates = [0, 1, 2];

const List<String> actions = [
  'volume_up',
  'volume_down',
  'mute',
  'play_pause',
  'next',
  'prev',
  'next_track',
  'prev_track',
  'volume_max',
  'volume_min',
  'hard_mute',
  'scroll_up',
  'scroll_down',
  'back',
  'forward',
  'brightness_up',
  'brightness_down',
  'show_desktop',
  'open_browser',
  'open_url',
  'open_app',
  'change_mode',
  'hotkey',
  'next_slide',
  'prev_slide',
  'start_present',
  'left_click',
  'right_click',
  'execute_cmd',
  'sequence',
  'delay',
  'mouse_move',
  'scroll',
  'mouse_mode',
];

class MacroStep {
  final String action;
  final String? value;

  const MacroStep({required this.action, this.value});

  factory MacroStep.fromJson(Map<String, dynamic> json) {
    return MacroStep(
      action: json['action'] as String? ?? '',
      value: json['value'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'action': action};
    if (value != null) {
      map['value'] = value;
    }
    return map;
  }
}

class MacroData {
  final List<MacroStep> steps;
  final int repeat;

  const MacroData({required this.steps, this.repeat = 1});

  factory MacroData.fromJson(Map<String, dynamic> json) {
    final stepsList = (json['steps'] as List<dynamic>?)
            ?.map((e) =>
                MacroStep.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return MacroData(
      steps: stepsList,
      repeat: (json['repeat'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'steps': steps.map((s) => s.toJson()).toList(),
    };
    if (repeat != 1) {
      map['repeat'] = repeat;
    }
    return map;
  }
}

class GestureConfig {
  final String id;
  final String movement;
  final String orientation;
  final int indexState;
  final int middleState;
  final String actionKey;
  final String? actionValue;
  final String context;

  const GestureConfig({
    required this.id,
    required this.movement,
    required this.orientation,
    required this.indexState,
    required this.middleState,
    required this.actionKey,
    this.actionValue,
    required this.context,
  });

  factory GestureConfig.fromJson(Map<String, dynamic> json) {
    return GestureConfig(
      id: json['id'] as String? ?? '',
      movement: json['movement'] as String? ?? 'NONE',
      orientation: json['orientation'] as String? ?? 'ANY',
      indexState: (json['index_state'] as num?)?.toInt() ?? 0,
      middleState: (json['middle_state'] as num?)?.toInt() ?? 0,
      actionKey: json['action_key'] as String? ?? '',
      actionValue: json['action_value'] as String?,
      context: json['context'] as String? ?? 'GLOBAL',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'movement': movement,
        'orientation': orientation,
        'index_state': indexState,
        'middle_state': middleState,
        'action_key': actionKey,
        'action_value': actionValue,
        'context': context,
      };
}
