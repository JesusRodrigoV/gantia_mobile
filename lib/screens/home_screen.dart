import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/glove_state.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../widgets/neuromorphic_card.dart';
import '../widgets/gantia_header.dart';
import '../widgets/gesture_flash.dart';
import '../widgets/action_log.dart';
import '../widgets/status_dot.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _scrolled = false;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    final s = _scrollCtrl.offset > 20;
    if (s != _scrolled) setState(() => _scrolled = s);
  }

  @override
  Widget build(BuildContext context) {
    final gloveState = ref.watch(gloveStateProvider);
    final themeService = ref.watch(themeServiceProvider);
    final isDark = themeService.isDarkMode;

    return Scaffold(
      backgroundColor: context.surface50,
      body: SafeArea(
        child: Column(
          children: [
            GantiaHeader(
              scrolled: _scrolled,
              onLogout: () async {
                await ref.read(authServiceProvider).logout();
                ref.read(wsClientProvider).disconnect();
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Center(child: GestureFlash(event: gloveState.gestureDetected)),
                    const SizedBox(height: 16),

                    NeuromorphicCard(
                      showAccentLine: false,
                      padding: const EdgeInsets.all(16),
                      child: _buildConnectionStatus(gloveState),
                    ),
                    const SizedBox(height: 16),

                    NeuromorphicCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ACCIONES RECIENTES',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppColors.primary600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ActionLog(actions: ref.watch(actionLogProvider).recentActions),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    NeuromorphicCard(
                      padding: const EdgeInsets.all(16),
                      child: _buildDeviceInfo(gloveState),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(GloveState gloveState) {
    final statusText = _statusLabel(gloveState);

    return Column(
      children: [
        Row(
          children: [
            StatusDot(status: gloveState.connectionStatus, flowing: gloveState.dataFlowing),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.surfaceLight700,
                    ),
                  ),
                  if (gloveState.telemetry != null)
                    Text(
                      'Datos recibiendo',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.surfaceLight500,
                      ),
                    ),
                ],
              ),
            ),
            if (gloveState.dataFlowing)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flash_on, size: 12, color: AppColors.primary500),
                    SizedBox(width: 4),
                    Text(
                      'ACTIVO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (gloveState.waitingForDevice) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primary500.withAlpha(10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text(
                  'Conectado al servidor — esperando guante...',
                  style: TextStyle(fontSize: 12, color: AppColors.surfaceLight500),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDeviceInfo(GloveState gloveState) {
    final bt = ref.watch(btServiceProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DISPOSITIVOS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.primary600,
          ),
        ),
        const SizedBox(height: 12),
        _deviceRow(
          icon: Icons.back_hand,
          label: 'Guante',
          connected: gloveState.connectionStatus == ConnectionStatus.connected,
        ),
        const SizedBox(height: 8),
        _deviceRow(
          icon: Icons.bluetooth_audio,
          label: 'Parlante BT',
          connected: bt.isConnected,
          detail: bt.isConnected ? bt.connectedDevice : null,
        ),
      ],
    );
  }

  Widget _deviceRow({
    required IconData icon,
    required String label,
    required bool connected,
    String? detail,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surface100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          StatusDotSmall(active: connected),
          const SizedBox(width: 12),
          Icon(icon, size: 20, color: AppColors.primary500),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.surfaceLight700,
            ),
          ),
          const Spacer(),
          Text(
            connected ? 'Conectado' : 'Desconectado',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: connected ? AppColors.primary500 : AppColors.surfaceLight400,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(GloveState gloveState) {
    switch (gloveState.connectionStatus) {
      case ConnectionStatus.connected:
        if (gloveState.dataFlowing) return 'Guante conectado — recibiendo datos';
        if (gloveState.waitingForDevice) return 'Conectado al servidor — esperando guante';
        return 'Conectado — sin datos';
      case ConnectionStatus.connecting:
        return 'Conectando al servidor...';
      case ConnectionStatus.disconnected:
        return 'Sin conexión';
      case ConnectionStatus.error:
        return 'Error de conexión';
    }
  }
}
