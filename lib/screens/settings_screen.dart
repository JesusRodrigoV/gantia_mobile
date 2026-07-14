import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../widgets/settings_card.dart';
import '../widgets/gantia_button.dart';
import '../models/gesture_config_model.dart';
import '../models/sensitivity_model.dart';


class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _btScanning = false;
  bool _sensLoaded = false;
  final Map<String, Timer> _sensTimers = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(sensitivityServiceProvider).getSettings().then((_) {
        if (mounted) setState(() => _sensLoaded = true);
      });
      ref.read(mouseConfigServiceProvider).getConfig();
      ref.read(targetServiceProvider).getTarget();
    });
  }

  @override
  void dispose() {
    for (final t in _sensTimers.values) {
      t.cancel();
    }
    _sensTimers.clear();
    super.dispose();
  }

  void _scanBt() async {
    setState(() => _btScanning = true);
    try {
      await ref.read(btServiceProvider).scanDevices();
    } finally {
      setState(() => _btScanning = false);
    }
  }

  void _updateSensitivity(String key, double value) {
    _sensTimers[key]?.cancel();
    _sensTimers[key] = Timer(const Duration(milliseconds: 300), () {
      _sensTimers.remove(key);
      ref.read(sensitivityServiceProvider).updateSettings({key: value});
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final themeService = ref.watch(themeServiceProvider);
    final btService = ref.watch(btServiceProvider);
    final gloveState = ref.watch(gloveStateProvider);
    final sensSvc = ref.watch(sensitivityServiceProvider);
    final mouseSvc = ref.watch(mouseConfigServiceProvider);
    final targetSvc = ref.watch(targetServiceProvider);

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
                  const Icon(Icons.settings, color: AppColors.primary500, size: 28),
                  const SizedBox(width: Spacing.xs),
                  const Text(
                    'Ajustes',
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
                  // ── Apariencia ──
                  SettingsCard(
                    icon: Icons.palette,
                    title: 'Apariencia',
                    description: 'Alternar entre tema claro y oscuro',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          themeService.isDarkMode ? 'Modo Oscuro' : 'Modo Claro',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.surfaceLight700,
                          ),
                        ),
                        Switch(
                          value: themeService.isDarkMode,
                          onChanged: (_) => themeService.toggleTheme(),
                          activeThumbColor: AppColors.primary500,
                        ),
                      ],
                    ),
                  ),

                  // ── Sensibilidad ──
                  SettingsCard(
                    icon: Icons.tune,
                    title: 'Sensibilidad',
                    description: 'Ajustá la sensibilidad de cada control del guante',
                    child: sensSvc.isLoading && !_sensLoaded
                        ? const Center(child: CircularProgressIndicator())
                        : sensSvc.settings == null
                            ? GantiaButton(
                                label: 'Cargar',
                                icon: Icons.refresh,
                                onPressed: () => ref.read(sensitivityServiceProvider).getSettings(),
                              )
                            : _buildSensitivitySliders(sensSvc.settings!),
                  ),

                  // ── Mouse ──
                  SettingsCard(
                    icon: Icons.mouse,
                    title: 'Mouse',
                    description: 'Invertí la dirección del cursor',
                    child: mouseSvc.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildMouseConfig(mouseSvc),
                  ),

                  // ── Contexto y Destino ──
                  SettingsCard(
                    icon: Icons.share,
                    title: 'Contexto y Destino',
                    child: Column(
                      children: [
                        _buildModeSelector(gloveState),
                        const Divider(height: Spacing.lg),
                        _buildTargetSelector(targetSvc),
                      ],
                    ),
                  ),

                  // ── Bluetooth ──
                  SettingsCard(
                    icon: Icons.bluetooth,
                    title: 'Parlante Bluetooth',
                    description: 'Conectá un parlante Bluetooth para control de audio',
                    child: Column(
                      children: [
                        if (btService.isConnected)
                          Padding(
                            padding: const EdgeInsets.only(bottom: Spacing.sm),
                            child: Container(
                              padding: const EdgeInsets.all(Spacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.primary500.withAlpha(15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.bluetooth_connected,
                                      color: AppColors.primary500, size: 20),
                                  const SizedBox(width: Spacing.xs),
                                  Expanded(
                                    child: Text(
                                      btService.connectedDevice ?? 'Conectado',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary600,
                                      ),
                                    ),
                                  ),
                                  GantiaButton(
                                    label: 'Desconectar',
                                    variant: GantiaButtonVariant.danger,
                                    onPressed: () => btService.disconnect(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        GantiaButton(
                          label: _btScanning ? 'Escaneando...' : 'Escanear dispositivos',
                          icon: Icons.search,
                          isLoading: _btScanning,
                          onPressed: _btScanning ? null : _scanBt,
                        ),
                        if (btService.availableDevices.isNotEmpty) ...[
                          const SizedBox(height: Spacing.xs),
                          ...btService.availableDevices.map(
                            (d) => ListTile(
                              dense: true,
                              title: Text(d, style: const TextStyle(fontSize: 13)),
                              trailing: GantiaButton(
                                label: 'Conectar',
                                onPressed: () => btService.connect(d),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── Acerca de ──
                  SettingsCard(
                    icon: Icons.info,
                    title: 'Acerca de',
                    child: const Text(
                      'Gantia Mobile v0.1.0',
                      style: TextStyle(fontSize: 13, color: AppColors.surfaceLight500),
                    ),
                  ),

                  const SizedBox(height: Spacing.sm),
                  GantiaButton(
                    label: 'Cerrar sesión',
                    icon: Icons.logout,
                    variant: GantiaButtonVariant.danger,
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Cerrar sesión'),
                          content: const Text('¿Estás seguro de que querés cerrar sesión?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Cerrar sesión'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        ref.read(wsClientProvider).disconnect();
                        await authService.logout();
                      }
                    },
                  ),
                  const SizedBox(height: Spacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensitivitySliders(SensitivitySettings s) {
    return Column(
      children: sensitivityFields.map((f) {
        double currentValue;
        switch (f.key) {
          case 'swipe_threshold': currentValue = s.swipeThreshold; break;
          case 'swipe_dominance': currentValue = s.swipeDominance; break;
          case 'swipe_cooldown': currentValue = s.swipeCooldown; break;
          case 'posture_hold_time': currentValue = s.postureHoldTime; break;
          case 'mouse_speed': currentValue = s.mouseSpeed; break;
          case 'mouse_dead_zone': currentValue = s.mouseDeadZone; break;
          case 'double_tap_window': currentValue = s.doubleTapWindow; break;
          case 'tilt_threshold': currentValue = s.tiltThreshold; break;
          case 'tilt_cooldown': currentValue = s.tiltCooldown; break;
          default: currentValue = 0;
        }

        final isSaving = _sensTimers.containsKey(f.key);

        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      f.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.surfaceLight700,
                      ),
                    ),
                  ),
                  Text(
                    f.key == 'swipe_dominance' || f.key == 'mouse_dead_zone'
                        ? currentValue.toStringAsFixed(2)
                        : (currentValue % 1 == 0
                            ? currentValue.toInt().toString()
                            : currentValue.toStringAsFixed(1)),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSaving ? AppColors.primary500 : AppColors.surfaceLight500,
                    ),
                  ),
                  if (isSaving)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: SizedBox(
                        width: 10, height: 10,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                    ),
                ],
              ),
              Text(
                f.desc,
                style: const TextStyle(fontSize: 11, color: AppColors.surfaceLight400),
              ),
              Slider(
                value: currentValue.clamp(f.min, f.max),
                min: f.min,
                max: f.max,
                divisions: ((f.max - f.min) / f.step).round().clamp(1, 200),
                onChanged: (v) => _updateSensitivity(f.key, v),
                activeColor: AppColors.primary500,
                inactiveColor: context.surface200,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMouseConfig(MouseConfigService svc) {
    final cfg = svc.config;
    final invertRoll = cfg?['invert_roll'] == true;
    final invertPitch = cfg?['invert_pitch'] == true;
    return Column(
      children: [
        _toggleRow(
          icon: Icons.swap_horiz,
          label: 'Invertir Balanceo (Roll)',
          value: invertRoll,
          onChanged: (v) => ref.read(mouseConfigServiceProvider).updateConfig(invertRoll: v),
        ),
        const SizedBox(height: Spacing.xs),
        _toggleRow(
          icon: Icons.swap_vert,
          label: 'Invertir Inclinación (Pitch)',
          value: invertPitch,
          onChanged: (v) => ref.read(mouseConfigServiceProvider).updateConfig(invertPitch: v),
        ),
      ],
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.surfaceLight500),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.surfaceLight600),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary500,
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(GloveState gloveState) {
    return Row(
      children: [
        const Text(
          'Modo activo:',
          style: TextStyle(fontSize: 13, color: AppColors.surfaceLight600),
        ),
        const Spacer(),
        DropdownButton<String>(
          value: contexts.contains(gloveState.currentMode)
              ? gloveState.currentMode
              : 'GLOBAL',
          underline: const SizedBox(),
          items: contexts
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(getContextLabel(c)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              ref.read(gloveStateProvider).changeMode(v);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTargetSelector(TargetService svc) {
    const targets = ['auto', 'pico_w', 'mobile'];
    const targetLabels = {'auto': 'Automático', 'pico_w': 'Pico W (PC)', 'mobile': 'Móvil'};

    return Row(
      children: [
        const Text(
          'Destino acciones:',
          style: TextStyle(fontSize: 13, color: AppColors.surfaceLight600),
        ),
        const Spacer(),
        DropdownButton<String>(
          value: targets.contains(svc.target) ? svc.target! : 'auto',
          underline: const SizedBox(),
          items: targets
              .map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(targetLabels[t] ?? t),
                  ))
              .toList(),
          onChanged: svc.isLoading
              ? null
              : (v) {
                  if (v != null) {
                    ref.read(targetServiceProvider).setTarget(v);
                  }
                },
        ),
      ],
    );
  }
}
