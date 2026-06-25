class SensitivitySettings {
  final double swipeThreshold;
  final double swipeDominance;
  final double swipeCooldown;
  final double postureHoldTime;
  final double mouseSpeed;
  final double mouseDeadZone;
  final double doubleTapWindow;
  final double tiltThreshold;
  final double tiltCooldown;

  const SensitivitySettings({
    this.swipeThreshold = 200,
    this.swipeDominance = 0.7,
    this.swipeCooldown = 1.5,
    this.postureHoldTime = 2.0,
    this.mouseSpeed = 150,
    this.mouseDeadZone = 0.03,
    this.doubleTapWindow = 0.3,
    this.tiltThreshold = 0.5,
    this.tiltCooldown = 0.2,
  });

  factory SensitivitySettings.fromJson(Map<String, dynamic> json) {
    return SensitivitySettings(
      swipeThreshold: (json['swipe_threshold'] as num?)?.toDouble() ?? 200,
      swipeDominance: (json['swipe_dominance'] as num?)?.toDouble() ?? 0.7,
      swipeCooldown: (json['swipe_cooldown'] as num?)?.toDouble() ?? 1.5,
      postureHoldTime: (json['posture_hold_time'] as num?)?.toDouble() ?? 2.0,
      mouseSpeed: (json['mouse_speed'] as num?)?.toDouble() ?? 150,
      mouseDeadZone: (json['mouse_dead_zone'] as num?)?.toDouble() ?? 0.03,
      doubleTapWindow: (json['double_tap_window'] as num?)?.toDouble() ?? 0.3,
      tiltThreshold: (json['tilt_threshold'] as num?)?.toDouble() ?? 0.5,
      tiltCooldown: (json['tilt_cooldown'] as num?)?.toDouble() ?? 0.2,
    );
  }

  Map<String, dynamic> toJson() => {
        'swipe_threshold': swipeThreshold,
        'swipe_dominance': swipeDominance,
        'swipe_cooldown': swipeCooldown,
        'posture_hold_time': postureHoldTime,
        'mouse_speed': mouseSpeed,
        'mouse_dead_zone': mouseDeadZone,
        'double_tap_window': doubleTapWindow,
        'tilt_threshold': tiltThreshold,
        'tilt_cooldown': tiltCooldown,
      };
}

const sensitivityFields = [
  _SensitivityField(
    key: 'swipe_threshold',
    label: 'Sensibilidad Swipe',
    desc: 'Qué tan fuerte debe ser el movimiento para detectar un swipe',
    min: 50,
    max: 500,
    step: 10,
  ),
  _SensitivityField(
    key: 'swipe_dominance',
    label: 'Dirección Swipe',
    desc: '0.5 balanceado, 1 muy estricto',
    min: 0,
    max: 1,
    step: 0.05,
  ),
  _SensitivityField(
    key: 'swipe_cooldown',
    label: 'Pausa Swipe',
    desc: 'Tiempo de espera entre swipes',
    min: 0.1,
    max: 5,
    step: 0.1,
  ),
  _SensitivityField(
    key: 'posture_hold_time',
    label: 'Tiempo Postura',
    desc: 'Segundos para activar una postura',
    min: 0.5,
    max: 5,
    step: 0.1,
  ),
  _SensitivityField(
    key: 'mouse_speed',
    label: 'Velocidad Mouse',
    desc: 'Velocidad del cursor en modo mouse',
    min: 10,
    max: 500,
    step: 10,
  ),
  _SensitivityField(
    key: 'mouse_dead_zone',
    label: 'Zona Muerta Mouse',
    desc: 'Movimiento ignorado antes de reaccionar',
    min: 0,
    max: 1,
    step: 0.01,
  ),
  _SensitivityField(
    key: 'double_tap_window',
    label: 'Ventana Doble Tap',
    desc: 'Tiempo para reconocer dos taps',
    min: 0.1,
    max: 1,
    step: 0.05,
  ),
  _SensitivityField(
    key: 'tilt_threshold',
    label: 'Sensibilidad Tilt',
    desc: 'Ángulo mínimo para detectar inclinación',
    min: 0.1,
    max: 1.5,
    step: 0.05,
  ),
  _SensitivityField(
    key: 'tilt_cooldown',
    label: 'Pausa Tilt',
    desc: 'Tiempo entre detecciones de tilt',
    min: 0.05,
    max: 1,
    step: 0.05,
  ),
];

class _SensitivityField {
  final String key;
  final String label;
  final String desc;
  final double min;
  final double max;
  final double step;

  const _SensitivityField({
    required this.key,
    required this.label,
    required this.desc,
    required this.min,
    required this.max,
    required this.step,
  });
}
