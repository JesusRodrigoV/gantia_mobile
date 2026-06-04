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
];

const Map<String, String> contextLabels = {
  'GLOBAL': 'Global',
  'AUDIO': 'Audio',
  'PRESENTATION': 'Presentación',
  'WORK': 'Trabajo',
  'WORKSHOP': 'Workshop',
};

String getContextLabel(String c) => contextLabels[c] ?? c;

const Map<String, String> movementLabels = {
  'NONE': 'Ninguno',
  'SWIPE_UP': 'Arriba ↑',
  'SWIPE_DOWN': 'Abajo ↓',
  'SWIPE_LEFT': 'Izquierda ←',
  'SWIPE_RIGHT': 'Derecha →',
  'TWIST': 'Giro',
};

String getMovementLabel(String m) => movementLabels[m] ?? m;

const Map<String, String> orientationLabels = {
  'ANY': 'Cualquiera',
  'PALM_UP': 'Palma Arriba',
  'PALM_DOWN': 'Palma Abajo',
  'UP': 'Hacia Arriba',
  'DOWN': 'Hacia Abajo',
  'NEUTRAL': 'Neutral',
};

String getOrientationLabel(String o) => orientationLabels[o] ?? o;

const Map<int, String> flexStateLabelsConfig = {
  0: 'Abierto',
  1: 'Parcial',
  2: 'Flexionado',
};

String getFlexStateLabel(int s) => flexStateLabelsConfig[s] ?? s.toString();

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
