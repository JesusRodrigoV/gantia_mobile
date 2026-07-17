import 'package:flutter/material.dart';
import '../models/smart_home_device.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import 'gantia_button.dart';
import 'settings_card.dart';
import 'smart_light_card.dart';

class DeviceErrorBanner extends StatelessWidget {
  final String? error;
  final VoidCallback onDismiss;

  const DeviceErrorBanner({super.key, required this.error, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    if (error == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: AppColors.red500.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, size: 16, color: AppColors.red500),
        const SizedBox(width: Spacing.xs),
        Expanded(child: Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.red500))),
        GestureDetector(onTap: onDismiss, child: const Icon(Icons.close, size: 16, color: AppColors.red500)),
      ]),
    );
  }
}

class SmartHomeDeviceSection extends StatefulWidget {
  final List<DeviceState> devices;
  final String? error;
  final Future<bool> Function(int index, bool on) onToggle;
  final Future<bool> Function(int index, int value) onBrightness;
  final void Function(int index) onRemove;
  final void Function(String name, String url) onAddDevice;
  final VoidCallback onDismissError;

  const SmartHomeDeviceSection({
    super.key,
    required this.devices,
    this.error,
    required this.onToggle,
    required this.onBrightness,
    required this.onRemove,
    required this.onAddDevice,
    required this.onDismissError,
  });

  @override
  State<SmartHomeDeviceSection> createState() => _SmartHomeDeviceSectionState();
}

class _SmartHomeDeviceSectionState extends State<SmartHomeDeviceSection> {
  final _nameCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DeviceErrorBanner(error: widget.error, onDismiss: widget.onDismissError),
        SettingsCard(
          icon: Icons.add,
          title: 'Agregar Dispositivo',
          child: Column(children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre (opcional)', hintText: 'Ej: Luz Escritorio',
              ),
            ),
            const SizedBox(height: Spacing.xs),
            TextField(
              controller: _urlCtrl,
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
              onPressed: () {
                widget.onAddDevice(_nameCtrl.text.trim(), _urlCtrl.text.trim());
                _nameCtrl.clear();
                _urlCtrl.clear();
              },
              minWidth: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
            ),
          ]),
        ),
        if (widget.devices.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.xxxl),
            child: Center(
              child: Text('Sin dispositivos configurados',
                style: TextStyle(fontSize: 13, color: context.surface500, fontStyle: FontStyle.italic)),
            ),
          )
        else
          ...widget.devices.asMap().entries.map((e) => SmartLightCard(
            device: e.value,
            onToggle: (on) => widget.onToggle(e.key, on),
            onBrightness: (value) => widget.onBrightness(e.key, value),
            onRemove: () => widget.onRemove(e.key),
          )),
      ],
    );
  }
}
