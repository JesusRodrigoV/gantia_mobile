import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sensitivity_model.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import 'gantia_button.dart';

class SensitivitySliders extends ConsumerStatefulWidget {
  const SensitivitySliders({super.key});

  @override
  ConsumerState<SensitivitySliders> createState() => _SensitivitySlidersState();
}

class _SensitivitySlidersState extends ConsumerState<SensitivitySliders> {
  bool _loaded = false;
  final Map<String, Timer> _debounceTimers = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(sensitivityServiceProvider).getSettings().then((_) {
        if (mounted) setState(() => _loaded = true);
      });
    });
  }

  @override
  void dispose() {
    for (final t in _debounceTimers.values) t.cancel();
    _debounceTimers.clear();
    super.dispose();
  }

  void _update(String key, double value) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(const Duration(milliseconds: 300), () {
      _debounceTimers.remove(key);
      ref.read(sensitivityServiceProvider).updateSettings({key: value});
    });
  }

  @override
  Widget build(BuildContext context) {
    final svc = ref.watch(sensitivityServiceProvider);
    if (svc.isLoading && !_loaded) return const Center(child: CircularProgressIndicator());
    if (svc.settings == null) {
      return GantiaButton(
        label: 'Cargar',
        icon: Icons.refresh,
        onPressed: () => ref.read(sensitivityServiceProvider).getSettings(),
      );
    }
    return Column(
      children: sensitivityFields.map((f) {
        double currentValue;
        switch (f.key) {
          case 'swipe_threshold': currentValue = svc.settings!.swipeThreshold; break;
          case 'swipe_dominance': currentValue = svc.settings!.swipeDominance; break;
          case 'swipe_cooldown': currentValue = svc.settings!.swipeCooldown; break;
          case 'posture_hold_time': currentValue = svc.settings!.postureHoldTime; break;
          case 'mouse_speed': currentValue = svc.settings!.mouseSpeed; break;
          case 'mouse_dead_zone': currentValue = svc.settings!.mouseDeadZone; break;
          case 'double_tap_window': currentValue = svc.settings!.doubleTapWindow; break;
          case 'tilt_threshold': currentValue = svc.settings!.tiltThreshold; break;
          case 'tilt_cooldown': currentValue = svc.settings!.tiltCooldown; break;
          default: currentValue = 0;
        }
        final isSaving = _debounceTimers.containsKey(f.key);

        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(f.label,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.surface800))),
                Text(
                  f.key == 'swipe_dominance' || f.key == 'mouse_dead_zone'
                      ? currentValue.toStringAsFixed(2)
                      : (currentValue % 1 == 0 ? currentValue.toInt().toString() : currentValue.toStringAsFixed(1)),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: isSaving ? AppColors.primary500 : context.surface600)),
                if (isSaving)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: SizedBox(width: 10, height: 10,
                      child: CircularProgressIndicator(strokeWidth: 1.5)),
                  ),
              ]),
              Text(f.desc, style: TextStyle(fontSize: 11, color: context.surface500)),
              Slider(
                value: currentValue.clamp(f.min, f.max),
                min: f.min, max: f.max,
                divisions: ((f.max - f.min) / f.step).round().clamp(1, 200),
                onChanged: (v) => _update(f.key, v),
                activeColor: AppColors.primary500,
                inactiveColor: context.surface200,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
