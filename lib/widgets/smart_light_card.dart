import 'package:flutter/material.dart';
import '../models/smart_home_device.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import 'gantia_button.dart';
import 'settings_card.dart';

class SmartLightCard extends StatefulWidget {
  final DeviceState device;
  final Future<bool> Function(bool isOn) onToggle;
  final Future<bool> Function(int brightness) onBrightness;
  final VoidCallback onRemove;

  const SmartLightCard({
    super.key,
    required this.device,
    required this.onToggle,
    required this.onBrightness,
    required this.onRemove,
  });

  @override
  State<SmartLightCard> createState() => _SmartLightCardState();
}

class _SmartLightCardState extends State<SmartLightCard> {
  late double _brightness;

  @override
  void initState() {
    super.initState();
    _brightness = widget.device.brightness;
  }

  @override
  void didUpdateWidget(SmartLightCard old) {
    super.didUpdateWidget(old);
    if (widget.device.name != old.device.name || widget.device.url != old.device.url) {
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
                    color: device.isOn ? AppColors.warning500 : context.surface500,
                    size: 24,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    device.url,
                    style: TextStyle(fontSize: 11, color: context.surface600),
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
                Icon(Icons.brightness_low, size: 16, color: context.surface600),
                Expanded(
                  child: Slider(
                    value: _brightness,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    onChanged: (v) => setState(() => _brightness = v),
                    onChangeEnd: (v) => widget.onBrightness(v.round()),
                    inactiveColor: context.surface300,
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
