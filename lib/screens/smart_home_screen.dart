import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../widgets/settings_card.dart';
import '../widgets/gantia_button.dart';

class SmartHomeScreen extends ConsumerStatefulWidget {
  const SmartHomeScreen({super.key});

  @override
  ConsumerState<SmartHomeScreen> createState() => _SmartHomeScreenState();
}

class _SmartHomeScreenState extends ConsumerState<SmartHomeScreen> {
  final List<_LightDevice> _devices = [];
  final _urlCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _urlCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _addDevice() {
    if (_urlCtrl.text.trim().isEmpty) return;
    setState(() {
      _devices.add(_LightDevice(
        name: _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : 'Luz ${_devices.length + 1}',
        url: _urlCtrl.text.trim(),
      ));
      _urlCtrl.clear();
      _nameCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final smartHomeService = ref.watch(smartHomeServiceProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surfaceDark50
          : AppColors.surfaceLight50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: AppColors.primary500, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'Smart Home',
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  SettingsCard(
                    icon: Icons.add,
                    title: 'Agregar Dispositivo',
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nombre (opcional)',
                            hintText: 'Ej: Luz Escritorio',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _urlCtrl,
                          decoration: const InputDecoration(
                            labelText: 'URL del dispositivo',
                            hintText: 'http://192.168.1.100/api/light',
                          ),
                        ),
                        const SizedBox(height: 12),
                        GantiaButton(
                          label: 'Agregar',
                          icon: Icons.add,
                          variant: GantiaButtonVariant.primary,
                          onPressed: _addDevice,
                          minWidth: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ],
                    ),
                  ),

                  if (_devices.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
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
                              if (on) {
                                smartHomeService.lightOn(entry.value.url);
                              } else {
                                smartHomeService.lightOff(entry.value.url);
                              }
                            },
                            onBrightness: (value) {
                              smartHomeService.setBrightness(entry.value.url, value);
                            },
                            onRemove: () => setState(() => _devices.removeAt(entry.key)),
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
}

class _LightDevice {
  final String name;
  final String url;
  bool isOn = false;
  double brightness = 50;

  _LightDevice({
    required this.name,
    required this.url,
  });
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
  Widget build(BuildContext context) {
    return SettingsCard(
      title: widget.device.name,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    widget.device.isOn ? Icons.lightbulb : Icons.lightbulb_outline,
                    color: widget.device.isOn ? AppColors.warning500 : AppColors.surfaceLight400,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.device.url,
                    style: const TextStyle(fontSize: 11, color: AppColors.surfaceLight500),
                  ),
                ],
              ),
              Switch(
                value: widget.device.isOn,
                onChanged: (v) {
                  setState(() => widget.device.isOn = v);
                  widget.onToggle(v);
                },
                activeThumbColor: AppColors.primary500,
              ),
            ],
          ),
          if (widget.device.isOn) ...[
            const SizedBox(height: 12),
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
                    onChangeEnd: (v) {
                      widget.device.brightness = v;
                      widget.onBrightness(v.round());
                    },
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
            child: TextButton.icon(
              onPressed: widget.onRemove,
              icon: const Icon(Icons.delete, size: 16, color: AppColors.red500),
              label: const Text(
                'Eliminar',
                style: TextStyle(fontSize: 12, color: AppColors.red500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
