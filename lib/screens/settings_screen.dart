import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../widgets/settings_card.dart';
import '../widgets/gantia_button.dart';
import '../models/gesture_config_model.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _btScanning = false;

  void _scanBt() async {
    setState(() => _btScanning = true);
    try {
      await ref.read(btServiceProvider).scanDevices();
    } finally {
      setState(() => _btScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final themeService = ref.watch(themeServiceProvider);
    final btService = ref.watch(btServiceProvider);
    final gloveState = ref.watch(gloveStateProvider);

    return Scaffold(
      backgroundColor: context.surface50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.settings, color: AppColors.primary500, size: 28),
                  const SizedBox(width: 8),
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
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
                          value: isDark,
                          onChanged: (_) => themeService.toggleTheme(),
                          activeThumbColor: AppColors.primary500,
                        ),
                      ],
                    ),
                  ),

                  SettingsCard(
                    icon: Icons.bluetooth,
                    title: 'Parlante Bluetooth',
                    description: 'Conectá un parlante Bluetooth para control de audio',
                    child: Column(
                      children: [
                        if (btService.isConnected)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary500.withAlpha(15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.bluetooth_connected,
                                      color: AppColors.primary500, size: 20),
                                  const SizedBox(width: 8),
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
                          const SizedBox(height: 8),
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

                  SettingsCard(
                    icon: Icons.share,
                    title: 'Contexto y Destino',
                    child: Column(
                      children: [
                        Row(
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
                        ),
                      ],
                    ),
                  ),

                  SettingsCard(
                    icon: Icons.info,
                    title: 'Acerca de',
                    child: const Text(
                      'Gantia Mobile v0.1.0',
                      style: TextStyle(fontSize: 13, color: AppColors.surfaceLight500),
                    ),
                  ),

                  const SizedBox(height: 12),
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
                        await authService.logout();
                        ref.read(wsClientProvider).disconnect();
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
