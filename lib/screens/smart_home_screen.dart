import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../widgets/settings_card.dart';
import '../widgets/gantia_button.dart';

class SmartHomeScreen extends ConsumerStatefulWidget {
  const SmartHomeScreen({super.key});

  @override
  ConsumerState<SmartHomeScreen> createState() => _SmartHomeScreenState();
}

class _SmartHomeScreenState extends ConsumerState<SmartHomeScreen> {
  final List<_LightDevice> _devices = [];
  final List<_Scene> _scenes = [];
  String _urlInput = '';
  String _nameInput = '';
  String _sceneNameInput = '';

  @override
  void initState() {
    super.initState();
    _loadDevices();
    _loadScenes();
  }

  Future<void> _loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('smart_home_devices');
    if (raw == null) return;
    final list = jsonDecode(raw) as List<dynamic>;
    setState(() {
      _devices.addAll(list.map((e) => _LightDevice.fromJson(e as Map<String, dynamic>)));
    });
  }

  Future<void> _saveDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_devices.map((d) => d.toJson()).toList());
    await prefs.setString('smart_home_devices', raw);
  }

  Future<void> _loadScenes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('smart_home_scenes');
    if (raw == null) return;
    final list = jsonDecode(raw) as List<dynamic>;
    setState(() {
      _scenes.addAll(list.map((e) => _Scene.fromJson(e as Map<String, dynamic>)));
    });
  }

  Future<void> _saveScenes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_scenes.map((s) => s.toJson()).toList());
    await prefs.setString('smart_home_scenes', raw);
  }

  void _addDevice() {
    if (_urlInput.trim().isEmpty) return;
    setState(() {
      _devices.add(_LightDevice(
        name: _nameInput.trim().isNotEmpty ? _nameInput.trim() : 'Luz ${_devices.length + 1}',
        url: _urlInput.trim(),
      ));
      _urlInput = '';
      _nameInput = '';
    });
    _saveDevices();
  }

  void _addScene() {
    final name = _sceneNameInput.trim();
    if (name.isEmpty) return;

    final snapshot = _devices
        .map((d) => _SceneDeviceState(name: d.name, url: d.url, isOn: d.isOn, brightness: d.brightness))
        .toList();

    setState(() {
      _scenes.add(_Scene(name: name, devices: snapshot));
      _sceneNameInput = '';
    });
    _saveScenes();
  }

  Future<void> _applyScene(_Scene scene) async {
    final smartHomeService = ref.read(smartHomeServiceProvider);
    for (final d in scene.devices) {
      if (d.isOn) {
        smartHomeService.lightOn(d.url);
        await Future<void>.delayed(const Duration(milliseconds: 100));
        if (d.brightness < 100) {
          smartHomeService.setBrightness(d.url, d.brightness.round());
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
      } else {
        smartHomeService.lightOff(d.url);
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Escena "${scene.name}" aplicada')),
      );
    }
  }

  void _deleteScene(int index) {
    setState(() => _scenes.removeAt(index));
    _saveScenes();
  }

  @override
  Widget build(BuildContext context) {
    final smartHomeService = ref.watch(smartHomeServiceProvider);

    return Scaffold(
      backgroundColor: context.surface50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, Spacing.xs),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: AppColors.primary500, size: 28),
                  const SizedBox(width: Spacing.xs),
                  const Text(
                    'Hogar Inteligente',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.surfaceLight700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                children: [
                  // ── Scene section ──
                  if (_scenes.isNotEmpty) ...[
                    SettingsCard(
                      icon: Icons.view_quilt,
                      title: 'ESCENAS',
                      child: Column(
                        children: [
                          ..._scenes.asMap().entries.map(
                                (entry) => _SceneCard(
                                  scene: entry.value,
                                  onApply: () => _applyScene(entry.value),
                                  onDelete: () => _deleteScene(entry.key),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],

                  // Add scene form
                  SettingsCard(
                    icon: Icons.add_circle_outline,
                    title: 'Agregar Escena',
                    description: 'Guarda el estado actual de todas las luces como una escena',
                    child: Builder(
                      builder: (context) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (v) => _sceneNameInput = v,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre de la escena',
                                  hintText: 'Ej: Apagar todo',
                                ),
                              ),
                            ),
                            const SizedBox(width: Spacing.sm),
                            GantiaButton(
                              label: 'Guardar',
                              icon: Icons.save,
                              variant: GantiaButtonVariant.primary,
                              onPressed: _scenes.length < 10 ? _addScene : null,
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // ── Add device form ──
                  SettingsCard(
                    icon: Icons.add,
                    title: 'Agregar Dispositivo',
                    child: Builder(
                      builder: (context) {
                        return Column(
                          children: [
                            TextField(
                              onChanged: (v) => _nameInput = v,
                              decoration: const InputDecoration(
                                labelText: 'Nombre (opcional)',
                                hintText: 'Ej: Luz Escritorio',
                              ),
                            ),
                            const SizedBox(height: Spacing.xs),
                            TextField(
                              onChanged: (v) => _urlInput = v,
                              decoration: const InputDecoration(
                                labelText: 'URL del dispositivo',
                                hintText: 'http://192.168.1.100/api/light',
                              ),
                            ),
                            const SizedBox(height: Spacing.sm),
                            GantiaButton(
                              label: 'Agregar',
                              icon: Icons.add,
                              variant: GantiaButtonVariant.primary,
                              onPressed: _addDevice,
                              minWidth: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // ── Device list ──
                  if (_devices.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: Spacing.xxxl),
                      child: Center(
                        child: Text(
                          'Sin dispositivos configurados',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.surfaceLight400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._devices.asMap().entries.map(
                          (entry) => _LightDeviceCard(
                            device: entry.value,
                            onToggle: (on) {
                              setState(() => _updateDevice(entry.key, isOn: on));
                              _saveDevices();
                              if (on) {
                                smartHomeService.lightOn(entry.value.url);
                              } else {
                                smartHomeService.lightOff(entry.value.url);
                              }
                            },
                            onBrightness: (value) {
                              setState(() => _updateDevice(entry.key, brightness: value.toDouble()));
                              _saveDevices();
                              smartHomeService.setBrightness(entry.value.url, value);
                            },
                            onRemove: () {
                              setState(() => _devices.removeAt(entry.key));
                              _saveDevices();
                            },
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateDevice(int index, {bool? isOn, double? brightness}) {
    final d = _devices[index];
    _devices[index] = _LightDevice(
      name: d.name,
      url: d.url,
      isOn: isOn ?? d.isOn,
      brightness: brightness ?? d.brightness,
    );
  }
}

// ── Models ──

class _LightDevice {
  final String name;
  final String url;
  final bool isOn;
  final double brightness;

  const _LightDevice({
    required this.name,
    required this.url,
    this.isOn = false,
    this.brightness = 50,
  });

  factory _LightDevice.fromJson(Map<String, dynamic> json) => _LightDevice(
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
}

class _SceneDeviceState {
  final String name;
  final String url;
  final bool isOn;
  final double brightness;

  const _SceneDeviceState({
    required this.name,
    required this.url,
    required this.isOn,
    required this.brightness,
  });

  factory _SceneDeviceState.fromJson(Map<String, dynamic> json) => _SceneDeviceState(
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

class _Scene {
  final String name;
  final List<_SceneDeviceState> devices;

  const _Scene({required this.name, required this.devices});

  factory _Scene.fromJson(Map<String, dynamic> json) => _Scene(
        name: json['name'] as String? ?? '',
        devices: (json['devices'] as List<dynamic>?)
                ?.map((e) => _SceneDeviceState.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'devices': devices.map((d) => d.toJson()).toList(),
      };
}

// ── Widgets ──

class _SceneCard extends StatelessWidget {
  final _Scene scene;
  final VoidCallback onApply;
  final VoidCallback onDelete;

  const _SceneCard({
    required this.scene,
    required this.onApply,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: context.surface100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.view_quilt, size: 20, color: AppColors.primary500),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scene.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.surfaceLight700,
                  ),
                ),
                Text(
                  '${scene.devices.where((d) => d.isOn).length}/${scene.devices.length} encendidas',
                  style: const TextStyle(fontSize: 11, color: AppColors.surfaceLight500),
                ),
              ],
            ),
          ),
          GantiaButton(
            label: 'Aplicar',
            icon: Icons.play_arrow,
            variant: GantiaButtonVariant.primary,
            onPressed: onApply,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          ),
          const SizedBox(width: Spacing.xxs),
          GantiaButton(
            label: '',
            icon: Icons.delete,
            variant: GantiaButtonVariant.danger,
            onPressed: onDelete,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ],
      ),
    );
  }
}

class _LightDeviceCard extends StatefulWidget {
  final _LightDevice device;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onBrightness;
  final VoidCallback onRemove;

  const _LightDeviceCard({
    required this.device,
    required this.onToggle,
    required this.onBrightness,
    required this.onRemove,
  });

  @override
  State<_LightDeviceCard> createState() => _LightDeviceCardState();
}

class _LightDeviceCardState extends State<_LightDeviceCard> {
  late double _brightness;

  @override
  void initState() {
    super.initState();
    _brightness = widget.device.brightness;
  }

  @override
  void didUpdateWidget(_LightDeviceCard old) {
    super.didUpdateWidget(old);
    if (widget.device != old.device) {
      _brightness = widget.device.brightness;
    }
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.device;
    return SettingsCard(
      title: device.name,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    device.isOn ? Icons.lightbulb : Icons.lightbulb_outline,
                    color: device.isOn ? AppColors.warning500 : AppColors.surfaceLight400,
                    size: 24,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    device.url,
                    style: const TextStyle(fontSize: 11, color: AppColors.surfaceLight500),
                  ),
                ],
              ),
              Switch(
                value: device.isOn,
                onChanged: (v) => widget.onToggle(v),
                activeThumbColor: AppColors.primary500,
              ),
            ],
          ),
          if (device.isOn) ...[
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                const Icon(Icons.brightness_low, size: 16, color: AppColors.surfaceLight500),
                Expanded(
                  child: Slider(
                    value: _brightness,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    onChanged: (v) => setState(() => _brightness = v),
                    onChangeEnd: (v) => widget.onBrightness(v.round()),
                    inactiveColor: AppColors.surfaceLight200,
                  ),
                ),
                Text(
                  '${_brightness.round()}%',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: GantiaButton(
              label: 'Eliminar',
              icon: Icons.delete,
              variant: GantiaButtonVariant.danger,
              onPressed: widget.onRemove,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
          ),
        ],
      ),
    );
  }
}
