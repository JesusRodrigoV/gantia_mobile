class GloveTelemetry {
  final int buttonPressed;
  final int flexIndex;
  final int flexMiddle;
  final int indexState;
  final int middleState;
  final double accelX;
  final double accelY;
  final double accelZ;
  final double gyroX;
  final double gyroY;
  final double gyroZ;

  const GloveTelemetry({
    required this.buttonPressed,
    required this.flexIndex,
    required this.flexMiddle,
    required this.indexState,
    required this.middleState,
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
  });

  factory GloveTelemetry.fromJson(Map<String, dynamic> json) {
    return GloveTelemetry(
      buttonPressed: (json['button_pressed'] as num?)?.toInt() ?? 0,
      flexIndex: (json['flex_index'] as num?)?.toInt() ?? 0,
      flexMiddle: (json['flex_middle'] as num?)?.toInt() ?? 0,
      indexState: (json['index_state'] as num?)?.toInt() ?? 0,
      middleState: (json['middle_state'] as num?)?.toInt() ?? 0,
      accelX: (json['accel_x'] as num?)?.toDouble() ?? 0.0,
      accelY: (json['accel_y'] as num?)?.toDouble() ?? 0.0,
      accelZ: (json['accel_z'] as num?)?.toDouble() ?? 0.0,
      gyroX: (json['gyro_x'] as num?)?.toDouble() ?? 0.0,
      gyroY: (json['gyro_y'] as num?)?.toDouble() ?? 0.0,
      gyroZ: (json['gyro_z'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'button_pressed': buttonPressed,
        'flex_index': flexIndex,
        'flex_middle': flexMiddle,
        'index_state': indexState,
        'middle_state': middleState,
        'accel_x': accelX,
        'accel_y': accelY,
        'accel_z': accelZ,
        'gyro_x': gyroX,
        'gyro_y': gyroY,
        'gyro_z': gyroZ,
      };
}

class ActionEvent {
  final String action;
  final dynamic actionValue;

  const ActionEvent({required this.action, this.actionValue});

  factory ActionEvent.fromJson(Map<String, dynamic> json) {
    if (json['action'] == 'action_triggered') {
      return ActionEvent(
        action: String(json['action_key'] ?? ''),
        actionValue: json['action_value'],
      );
    }
    return ActionEvent(
      action: json['action'] as String? ?? '',
      actionValue: json['action_value'],
    );
  }
}

class GestureDetectedEvent {
  final String type;
  final String gesture;
  final String action;

  const GestureDetectedEvent({
    required this.type,
    required this.gesture,
    required this.action,
  });

  factory GestureDetectedEvent.fromJson(Map<String, dynamic> json) {
    return GestureDetectedEvent(
      type: json['type'] as String? ?? '',
      gesture: json['gesture'] as String? ?? '',
      action: json['action'] as String? ?? '',
    );
  }
}

bool isGestureDetected(dynamic data) {
  return data is Map<String, dynamic> && data['type'] == 'gesture_detected';
}

bool isActionMessage(dynamic data) {
  return data is Map<String, dynamic> && data.containsKey('action');
}

bool isTelemetryData(dynamic data) {
  return data is Map<String, dynamic> && data.containsKey('accel_x');
}

const Map<String, String> actionLabels = {
  'mouse_mode': 'Mouse Mode',
  'volume_up': 'Subir Volumen',
  'volume_down': 'Bajar Volumen',
  'mute': 'Silenciar',
  'play_pause': 'Reproducir/Pausar',
  'next': 'Siguiente',
  'prev': 'Anterior',
  'scroll_up': 'Scroll Arriba',
  'scroll_down': 'Scroll Abajo',
  'back': 'Atrás',
  'forward': 'Adelante',
  'brightness_up': 'Brillo +',
  'brightness_down': 'Brillo -',
  'show_desktop': 'Mostrar Escritorio',
  'open_browser': 'Abrir Navegador',
  'open_url': 'Abrir URL',
  'open_app': 'Abrir App',
  'change_mode': 'Cambiar Modo',
  'hotkey': 'Hotkey',
  'next_slide': 'Siguiente Slide',
  'prev_slide': 'Slide Anterior',
  'start_present': 'Iniciar Presentación',
  'left_click': 'Click Izquierdo',
  'right_click': 'Click Derecho',
  'scroll': 'Scroll',
  'mouse_move': 'Mover Mouse',
  'execute_cmd': 'Ejecutar Comando',
  'sequence': 'Secuencia',
  'delay': 'Esperar',
  'light_on': 'Encender Luz',
  'light_off': 'Apagar Luz',
  'light_brightness': 'Brillo Luz',
};

String getActionLabel(String action) {
  return actionLabels[action] ?? action;
}

const Map<int, String> flexStateLabels = {
  0: 'Abierto',
  1: 'Parcial',
  2: 'Flexionado',
};
