import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/smart_home_device.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/smart_home_device_section.dart';
import '../widgets/smart_home_scene_section.dart';

class SmartHomeScreen extends ConsumerStatefulWidget {
  const SmartHomeScreen({super.key});

  @override
  ConsumerState<SmartHomeScreen> createState() => _SmartHomeScreenState();
}

class _SmartHomeScreenState extends ConsumerState<SmartHomeScreen> {
  static const int _maxScenes = 10;
  static const String _devicesKey = 'smart_home_devices';
  static const String _scenesKey = 'smart_home_scenes';

  final List<DeviceState> _devices = [];
  final List<Scene> _scenes = [];
  String? _deviceError;

  @override
  void initState() {
    super.initState();
    _loadDevices();
    _loadScenes();
  }

  void _clearError() {
    if (_deviceError != null) setState(() => _deviceError = null);
  }

  Future<void> _loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_devicesKey);
    if (raw == null) return;
    final list = jsonDecode(raw) as List<dynamic>;
    setState(() => _devices.addAll(list.map((e) => DeviceState.fromJson(e as Map<String, dynamic>))));
  }

  Future<void> _saveDevices() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_devicesKey, jsonEncode(_devices.map((d) => d.toJson()).toList()));
  }

  Future<void> _loadScenes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scenesKey);
    if (raw == null) return;
    final list = jsonDecode(raw) as List<dynamic>;
    setState(() => _scenes.addAll(list.map((e) => Scene.fromJson(e as Map<String, dynamic>))));
  }

  Future<void> _saveScenes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scenesKey, jsonEncode(_scenes.map((s) => s.toJson()).toList()));
  }

  void _addDevice(String name, String url) {
    if (url.isEmpty) return;
    setState(() {
      _devices.add(DeviceState(
        name: name.isNotEmpty ? name : 'Luz ${_devices.length + 1}',
        url: url,
      ));
    });
    _saveDevices();
  }

  void _addScene(String name) {
    if (name.isEmpty) return;
    setState(() {
      _scenes.add(Scene(
        name: name,
        devices: _devices.map((d) => DeviceState(
          name: d.name, url: d.url, isOn: d.isOn, brightness: d.brightness)).toList(),
      ));
    });
    _saveScenes();
  }

  Future<bool> _toggleDevice(int index, bool on) async {
    _clearError();
    setState(() => _devices[index] = _devices[index].copyWith(isOn: on));
    _saveDevices();
    final svc = ref.read(smartHomeServiceProvider);
    final ok = on ? await svc.lightOn(_devices[index].url) : await svc.lightOff(_devices[index].url);
    if (!ok && mounted) {
      setState(() {
        _deviceError = 'Error al ${on ? "encender" : "apagar"} ${_devices[index].name}';
        _devices[index] = _devices[index].copyWith(isOn: !on);
      });
      _saveDevices();
    }
    return ok;
  }

  Future<bool> _brightnessDevice(int index, int value) async {
    _clearError();
    setState(() => _devices[index] = _devices[index].copyWith(brightness: value.toDouble()));
    _saveDevices();
    final svc = ref.read(smartHomeServiceProvider);
    final ok = await svc.setBrightness(_devices[index].url, value);
    if (!ok && mounted) {
      setState(() => _deviceError = 'Error al ajustar brillo de ${_devices[index].name}');
    }
    return ok;
  }

  void _removeDevice(int index) {
    setState(() => _devices.removeAt(index));
    _saveDevices();
  }

  Future<void> _applyScene(Scene scene) async {
    final svc = ref.read(smartHomeServiceProvider);
    for (final d in scene.devices) {
      final ok = d.isOn ? await svc.lightOn(d.url) : await svc.lightOff(d.url);
      if (!ok) {
        _deviceError = 'Error al ${d.isOn ? "encender" : "apagar"} ${d.name}';
        if (mounted) setState(() {});
        return;
      }
      if (d.isOn && d.brightness < 100) {
        final ok2 = await svc.setBrightness(d.url, d.brightness.round());
        if (!ok2) {
          _deviceError = 'Error al ajustar brillo de ${d.name}';
          if (mounted) setState(() {});
          return;
        }
      }
    }
    if (mounted) {
      _clearError();
      showSuccessSnackBar(context, 'Escena "${scene.name}" aplicada');
    }
  }

  void _deleteScene(int index) {
    setState(() => _scenes.removeAt(index));
    _saveScenes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surface50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, Spacing.xs),
              child: Row(children: [
                const Icon(Icons.lightbulb, color: AppColors.primary500, size: 28),
                const SizedBox(width: Spacing.xs),
                Text('Hogar Inteligente',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: context.surface800)),
              ]),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                children: [
                  SmartHomeSceneSection(
                    scenes: _scenes,
                    maxScenes: _maxScenes,
                    onApplyScene: _applyScene,
                    onDeleteScene: _deleteScene,
                    onAddScene: _addScene,
                  ),
                  SmartHomeDeviceSection(
                    devices: _devices,
                    error: _deviceError,
                    onToggle: _toggleDevice,
                    onBrightness: _brightnessDevice,
                    onRemove: _removeDevice,
                    onAddDevice: _addDevice,
                    onDismissError: _clearError,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
