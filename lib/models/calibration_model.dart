class CalibrationEntry {
  final String sensorName;
  final double minValue;
  final double maxValue;

  const CalibrationEntry({
    required this.sensorName,
    required this.minValue,
    required this.maxValue,
  });

  factory CalibrationEntry.fromJson(Map<String, dynamic> json) {
    return CalibrationEntry(
      sensorName: json['sensor_name'] as String? ?? '',
      minValue: (json['min_value'] as num?)?.toDouble() ?? 0,
      maxValue: (json['max_value'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'sensor_name': sensorName,
        'min_value': minValue,
        'max_value': maxValue,
      };
}
