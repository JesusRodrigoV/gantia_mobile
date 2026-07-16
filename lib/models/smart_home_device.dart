class LightDevice {
  final String name;
  final String url;
  final bool isOn;
  final double brightness;

  const LightDevice({
    required this.name,
    required this.url,
    this.isOn = false,
    this.brightness = 50,
  });

  factory LightDevice.fromJson(Map<String, dynamic> json) => LightDevice(
        name: json['name'] as String? ?? '',
        url: json['url'] as String? ?? '',
        isOn: json['isOn'] as bool? ?? false,
        brightness: (json['brightness'] as num?)?.toDouble() ?? 50,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'isOn': isOn,
        'brightness': brightness,
      };

  LightDevice copyWith({bool? isOn, double? brightness}) => LightDevice(
        name: name,
        url: url,
        isOn: isOn ?? this.isOn,
        brightness: brightness ?? this.brightness,
      );
}

class SceneDeviceState {
  final String name;
  final String url;
  final bool isOn;
  final double brightness;

  const SceneDeviceState({
    required this.name,
    required this.url,
    required this.isOn,
    required this.brightness,
  });

  factory SceneDeviceState.fromJson(Map<String, dynamic> json) => SceneDeviceState(
        name: json['name'] as String? ?? '',
        url: json['url'] as String? ?? '',
        isOn: json['isOn'] as bool? ?? false,
        brightness: (json['brightness'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'isOn': isOn,
        'brightness': brightness,
      };
}

class Scene {
  final String name;
  final List<SceneDeviceState> devices;

  const Scene({required this.name, required this.devices});

  factory Scene.fromJson(Map<String, dynamic> json) => Scene(
        name: json['name'] as String? ?? '',
        devices: (json['devices'] as List<dynamic>?)
                ?.map((e) => SceneDeviceState.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'devices': devices.map((d) => d.toJson()).toList(),
      };
}
