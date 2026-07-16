import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gesture_config_model.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../widgets/bt_scanner_section.dart';
import '../widgets/gantia_button.dart';
import '../widgets/sensitivity_sliders.dart';
import '../widgets/settings_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(mouseConfigServiceProvider).getConfig();
      ref.read(targetServiceProvider).getTarget();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final themeService = ref.watch(themeServiceProvider);
    final mouseSvc = ref.watch(mouseConfigServiceProvider);
    final targetSvc = ref.watch(targetServiceProvider);
    final gloveState = ref.watch(gloveStateProvider);

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
                  Text('Ajustes',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: context.surface800)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                children: [
                  _appearanceCard(themeService),
                  _sensitivityCard(),
                  _mouseCard(mouseSvc),
                  _contextTargetCard(gloveState, targetSvc),
                  const BtScannerSection(),
                  _aboutCard(),
                  const SizedBox(height: Spacing.sm),
                  _logoutButton(authService),
                  const SizedBox(height: Spacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appearanceCard(ThemeService themeService) {
    return SettingsCard(
      icon: Icons.palette,
      title: 'Apariencia',
      description: 'Alternar entre tema claro y oscuro',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(themeService.isDarkMode ? 'Modo Oscuro' : 'Modo Claro',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.surface800)),
          Switch(
            value: themeService.isDarkMode,
            onChanged: (_) => themeService.toggleTheme(),
            activeThumbColor: AppColors.primary500,
          ),
        ],
      ),
    );
  }

  Widget _sensitivityCard() {
    return SettingsCard(
      icon: Icons.tune,
      title: 'Sensibilidad',
      description: 'Ajustá la sensibilidad de cada control del guante',
      child: const SensitivitySliders(),
    );
  }

  Widget _mouseCard(MouseConfigService svc) {
    final cfg = svc.config;
    return SettingsCard(
      icon: Icons.mouse,
      title: 'Mouse',
      description: 'Invertí la dirección del cursor',
      child: svc.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _toggleRow(Icons.swap_horiz, 'Invertir Balanceo (Roll)',
                  cfg?['invert_roll'] == true, (v) => svc.updateConfig(invertRoll: v)),
                const SizedBox(height: Spacing.xs),
                _toggleRow(Icons.swap_vert, 'Invertir Inclinación (Pitch)',
                  cfg?['invert_pitch'] == true, (v) => svc.updateConfig(invertPitch: v)),
              ],
            ),
    );
  }

  Widget _contextTargetCard(GloveState gloveState, TargetService svc) {
    const targets = ['auto', 'pico_w', 'mobile'];
    const targetLabels = {'auto': 'Automático', 'pico_w': 'Pico W (PC)', 'mobile': 'Móvil'};

    return SettingsCard(
      icon: Icons.share,
      title: 'Contexto y Destino',
      child: Column(
        children: [
          Row(children: [
            Text('Modo activo:', style: TextStyle(fontSize: 13, color: context.surface700)),
            const Spacer(),
            DropdownButton<String>(
              value: contexts.contains(gloveState.currentMode) ? gloveState.currentMode : 'GLOBAL',
              underline: const SizedBox(),
              items: contexts.map((c) => DropdownMenuItem(
                value: c, child: Text(getContextLabel(c)))).toList(),
              onChanged: (v) {
                if (v != null) ref.read(gloveStateProvider).changeMode(v);
              },
            ),
          ]),
          const Divider(height: Spacing.lg),
          Row(children: [
            Text('Destino acciones:', style: TextStyle(fontSize: 13, color: context.surface700)),
            const Spacer(),
            DropdownButton<String>(
              value: targets.contains(svc.target) ? svc.target! : 'auto',
              underline: const SizedBox(),
              items: targets.map((t) => DropdownMenuItem(
                value: t, child: Text(targetLabels[t] ?? t))).toList(),
              onChanged: svc.isLoading ? null : (v) {
                if (v != null) ref.read(targetServiceProvider).setTarget(v);
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _toggleRow(IconData icon, String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.surface600),
          const SizedBox(width: Spacing.xs),
          Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: context.surface700))),
          Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary500),
        ],
      ),
    );
  }

  Widget _aboutCard() {
    return SettingsCard(
      icon: Icons.info,
      title: 'Acerca de',
      child: Text('Gantia Mobile v0.1.0',
        style: TextStyle(fontSize: 13, color: context.surface600)),
    );
  }

  Widget _logoutButton(AuthService authService) {
    return GantiaButton(
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
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Cerrar sesión')),
            ],
          ),
        );
        if (confirm == true) {
          ref.read(wsClientProvider).disconnect();
          await authService.logout();
        }
      },
    );
  }
}
