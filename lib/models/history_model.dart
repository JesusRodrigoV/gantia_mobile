class HistoryReading {
  final double accelX;
  final double accelY;
  final double accelZ;
  final double gyroX;
  final double gyroY;
  final double gyroZ;
  final double flexIndex;
  final double flexMiddle;
  final DateTime timestamp;

  const HistoryReading({
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.flexIndex,
    required this.flexMiddle,
    required this.timestamp,
  });

  factory HistoryReading.fromJson(Map<String, dynamic> json) {
    return HistoryReading(
      accelX: (json['accel_x'] as num?)?.toDouble() ?? 0,
      accelY: (json['accel_y'] as num?)?.toDouble() ?? 0,
      accelZ: (json['accel_z'] as num?)?.toDouble() ?? 0,
      gyroX: (json['gyro_x'] as num?)?.toDouble() ?? 0,
      gyroY: (json['gyro_y'] as num?)?.toDouble() ?? 0,
      gyroZ: (json['gyro_z'] as num?)?.toDouble() ?? 0,
      flexIndex: (json['flex_index'] as num?)?.toDouble() ?? 0,
      flexMiddle: (json['flex_middle'] as num?)?.toDouble() ?? 0,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'accel_x': accelX,
        'accel_y': accelY,
        'accel_z': accelZ,
        'gyro_x': gyroX,
        'gyro_y': gyroY,
        'gyro_z': gyroZ,
        'flex_index': flexIndex,
        'flex_middle': flexMiddle,
        'timestamp': timestamp.toIso8601String(),
      };
}

class HistoryActionEntry {
  final String action;
  final String? actionValue;
  final String target;
  final String status;
  final int timestamp;

  const HistoryActionEntry({
    required this.action,
    this.actionValue,
    required this.target,
    required this.status,
    required this.timestamp,
  });

  factory HistoryActionEntry.fromJson(Map<String, dynamic> json) {
    return HistoryActionEntry(
      action: json['action'] as String? ?? '',
      actionValue: json['action_value']?.toString(),
      target: json['target'] as String? ?? '-',
      status: json['status'] as String? ?? '-',
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'action': action,
        if (actionValue != null) 'action_value': actionValue,
        'target': target,
        'status': status,
        'timestamp': timestamp,
      };
}
