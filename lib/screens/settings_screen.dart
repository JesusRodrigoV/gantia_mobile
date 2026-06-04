import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../services/bt_service.dart';
import '../services/ws_service.dart';
import '../theme/app_colors.dart';
import '../widgets/settings_card.dart';
import '../widgets/gantia_button.dart';
import '../models/gesture_config_model.dart';

class SettingsScreen extends StatefulWidget {
  final AuthService authService;
  final ThemeService themeService;
  final BtService btService;
  final WsService wsService;

  const SettingsScreen({
    super.key,
    required this.authService,
    required this.themeService,
    required this.btService,
    required this.wsService,
  });

  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _btScanning = false;

  void _scanBt() async {
    setState(() => _btScanning = true);
    await widget.btService.scanDevices();
    setState(() => _btScanning = false);
  }

  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark50 : AppColors.surfaceLight50,
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
                  // Theme
                  SettingsCard(
                    icon: Icons.palette,
                    title: 'Apariencia',
                    description: 'Alternar entre tema claro y oscuro',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isDark ? 'Modo Oscuro' : 'Modo Claro',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.surfaceLight700,
                          ),
                        ),
                        Switch(
                          value: isDark,
                          onChanged: (_) => widget.themeService.toggleTheme(),
                          activeColor: AppColors.primary500,
                        ),
                      ],
                    ),
                  ),

                  // Bluetooth
                  SettingsCard(
                    icon: Icons.bluetooth,
                    title: 'Parlante Bluetooth',
                    description: 'Conectá un parlante Bluetooth para control de audio',
                    child: Column(
                      children: [
                        if (widget.btService.isConnected)
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
                                      widget.btService.connectedDevice ?? 'Conectado',
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
                                    onPressed: () => widget.btService.disconnect(),
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
                        if (widget.btService.availableDevices.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ...widget.btService.availableDevices.map(
                            (d) => ListTile(
                              dense: true,
                              title: Text(d, style: const TextStyle(fontSize: 13)),
                              trailing: GantiaButton(
                                label: 'Conectar',
                                onPressed: () => widget.btService.connect(d),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Mode / Target
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
                              value: contexts.contains(widget.wsService.currentMode)
                                  ? widget.wsService.currentMode
                                  : 'GLOBAL',
                              underline: const SizedBox(),
                              items: contexts
                                  .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(getContextLabel(c)),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) setState(() {});
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // About
                  SettingsCard(
                    icon: Icons.info,
                    title: 'Acerca de',
                    child: const Text(
                      'Gantia Mobile v0.1.0',
                      style: TextStyle(fontSize: 13, color: AppColors.surfaceLight500),
                    ),
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
