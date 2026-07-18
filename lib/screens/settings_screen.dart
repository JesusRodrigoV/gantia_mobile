import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gesture_config_model.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../widgets/bt_status_section.dart';
import '../widgets/gantia_button.dart';
import '../widgets/neuromorphic_card.dart';
import '../widgets/sensitivity_sliders.dart';
import '../widgets/settings_card.dart';
import 'section_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.surface50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                children: [
                  _menuItem(
                    context,
                    icon: Icons.palette,
                    title: 'Apariencia',
                    subtitle: 'Alternar entre tema claro y oscuro',
                    child: const _AppearanceBody(),
                  ),
                  _menuItem(
                    context,
                    icon: Icons.tune,
                    title: 'Sensibilidad',
                    subtitle: 'Ajustá la sensibilidad de cada control del guante',
                    child: const _SensitivityBody(),
                  ),
                  _menuItem(
                    context,
                    icon: Icons.mouse,
                    title: 'Mouse',
                    subtitle: 'Configuración de puntero',
                    child: const _MouseConfigBody(),
                  ),
                  _menuItem(
                    context,
                    icon: Icons.share,
                    title: 'Contexto y Destino',
                    subtitle: 'Modo activo y destino de acciones',
                    child: const _ContextTargetBody(),
                  ),
                  _menuItem(
                    context,
                    icon: Icons.bluetooth,
                    title: 'Bluetooth',
                    subtitle: 'Conectá un parlante Bluetooth',
                    child: const BtStatusSection(),
                  ),
                  _aboutCard(context),
                  const SizedBox(height: Spacing.sm),
                  _logoutButton(context, ref),
                  const SizedBox(height: Spacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: NeuromorphicCard(
        showAccentLine: false,
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SectionScreen(
                  icon: icon,
                  title: title,
                  child: child,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.md,
              ),
              child: Row(
                children: [
                  Icon(icon, size: 22, color: AppColors.primary500),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.surface800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: context.surface500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 20, color: context.surface400),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, Spacing.xs),
      child: Row(
        children: [
          const Icon(Icons.settings, color: AppColors.primary500, size: 28),
          const SizedBox(width: Spacing.xs),
          Text('Ajustes',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: context.surface800)),
        ],
      ),
    );
  }

  Widget _aboutCard(BuildContext context) {
    return SettingsCard(
      icon: Icons.info,
      title: 'Acerca de',
      description: 'Versión de la aplicación',
      child: Text('Gantia Mobile v0.1.0',
        style: TextStyle(fontSize: 13, color: context.surface600)),
    );
  }

  Widget _logoutButton(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
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

class _AppearanceBody extends ConsumerWidget {
  const _AppearanceBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeServiceProvider.select((s) => s.isDarkMode));
    return SettingsCard(
      icon: Icons.palette,
      title: 'Tema',
      description: 'Alternar entre tema claro y oscuro',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(isDarkMode ? 'Modo Oscuro' : 'Modo Claro',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.surface800)),
          Switch(
            value: isDarkMode,
            onChanged: (_) => ref.read(themeServiceProvider).toggleTheme(),
            activeThumbColor: AppColors.primary500,
          ),
        ],
      ),
    );
  }
}

class _SensitivityBody extends ConsumerWidget {
  const _SensitivityBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SettingsCard(
      icon: Icons.tune,
      title: 'Sensibilidad',
      description: 'Ajustá la sensibilidad de cada control del guante',
      child: SensitivitySliders(),
    );
  }
}

class _MouseConfigBody extends ConsumerStatefulWidget {
  const _MouseConfigBody();

  @override
  ConsumerState<_MouseConfigBody> createState() => _MouseConfigBodyState();
}

class _MouseConfigBodyState extends ConsumerState<_MouseConfigBody> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      try {
        ref.read(mouseConfigServiceProvider).getConfig();
      } catch (e) {
        debugPrint('[MouseConfigBody] getConfig error: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final svc = ref.watch(mouseConfigServiceProvider);
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
}

class _ContextTargetBody extends ConsumerWidget {
  const _ContextTargetBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(gloveStateProvider.select((s) => s.currentMode));
    final targetSvc = ref.watch(targetServiceProvider);

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
              value: contexts.contains(currentMode) ? currentMode : 'GLOBAL',
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
              value: targets.contains(targetSvc.target) ? targetSvc.target! : 'auto',
              underline: const SizedBox(),
              items: targets.map((t) => DropdownMenuItem(
                value: t, child: Text(targetLabels[t] ?? t))).toList(),
              onChanged: targetSvc.isLoading ? null : (v) {
                if (v != null) ref.read(targetServiceProvider).setTarget(v);
              },
            ),
          ]),
        ],
      ),
    );
  }
}
