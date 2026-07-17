export '../utils/action_utils.dart' show isGestureDetected, isActionMessage, isTelemetryData, actionLabels, getActionLabel;

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
  final int? rssi;
  final double? tempMpu;
  final int? uptimeMs;

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
    this.rssi,
    this.tempMpu,
    this.uptimeMs,
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
      rssi: (json['rssi'] as num?)?.toInt(),
      tempMpu: (json['temp_mpu'] as num?)?.toDouble(),
      uptimeMs: (json['uptime_ms'] as num?)?.toInt(),
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
        if (rssi != null) 'rssi': rssi,
        if (tempMpu != null) 'temp_mpu': tempMpu,
        if (uptimeMs != null) 'uptime_ms': uptimeMs,
      };

  /// Whether this telemetry includes health data (Feature #8)
  bool get hasHealth => rssi != null;
}

class ActionEvent {
  final String action;
  final dynamic actionValue;

  const ActionEvent({required this.action, this.actionValue});

  factory ActionEvent.fromJson(Map<String, dynamic> json) {
    if (json['action'] == 'action_triggered') {
      return ActionEvent(
        action: (json['action_key'] as String?) ?? '',
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
