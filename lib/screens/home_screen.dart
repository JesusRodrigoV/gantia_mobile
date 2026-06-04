import 'package:flutter/material.dart';
import '../services/ws_service.dart';
import '../services/bt_service.dart';
import '../theme/app_colors.dart';
import '../widgets/neuromorphic_card.dart';
import '../widgets/gantia_header.dart';
import '../widgets/gesture_flash.dart';
import '../widgets/action_log.dart';
import '../widgets/status_dot.dart';

class HomeScreen extends StatefulWidget {
  final WsService wsService;
  final BtService btService;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final VoidCallback onLogout;

  const HomeScreen({
    super.key,
    required this.wsService,
    required this.btService,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onLogout,
  });

  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _scrolled = false;
  final _scrollCtrl = ScrollController();

  void initState() {
    super.initState();
    widget.wsService.addListener(_onWsChange);
    _scrollCtrl.addListener(_onScroll);
  }

  void dispose() {
    widget.wsService.removeListener(_onWsChange);
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onWsChange() => setState(() {});
  void _onScroll() {
    final s = _scrollCtrl.offset > 20;
    if (s != _scrolled) setState(() => _scrolled = s);
  }

  Widget build(BuildContext context) {
    final ws = widget.wsService;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surfaceDark50
          : AppColors.surfaceLight50,
      body: SafeArea(
        child: Column(
          children: [
            GantiaHeader(
              wsService: ws,
              isDarkMode: widget.isDarkMode,
              onThemeToggle: widget.onThemeToggle,
              onLogout: widget.onLogout,
              scrolled: _scrolled,
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Gesture Flash overlay
                    Center(child: GestureFlash(event: ws.gestureDetected)),
                    const SizedBox(height: 16),

                    // Connection status card
                    NeuromorphicCard(
                      showAccentLine: false,
                      padding: const EdgeInsets.all(16),
                      child: _buildConnectionStatus(ws),
                    ),
                    const SizedBox(height: 16),

                    // Recent actions
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
                          ActionLog(actions: ws.recentActions),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Device info
                    NeuromorphicCard(
                      padding: const EdgeInsets.all(16),
                      child: _buildDeviceInfo(ws),
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

  Widget _buildConnectionStatus(WsService ws) {
    final statusText = _statusLabel(ws);

    return Column(
      children: [
        Row(
          children: [
            StatusDot(status: ws.connectionStatus, flowing: ws.dataFlowing),
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
                  if (ws.telemetry != null)
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
            if (ws.dataFlowing)
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
        if (ws.waitingForDevice) ...[
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

  Widget _buildDeviceInfo(WsService ws) {
    final bt = widget.btService;
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
        // Glove status
        _deviceRow(
          icon: Icons.hand_gesture,
          label: 'Guante',
          connected: ws.connectionStatus == ConnectionStatus.connected,
        ),
        const SizedBox(height: 8),
        // BT Speaker
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
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark100
            : AppColors.surfaceLight100,
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

  String _statusLabel(WsService ws) {
    switch (ws.connectionStatus) {
      case ConnectionStatus.connected:
        if (ws.dataFlowing) return 'Guante conectado — recibiendo datos';
        if (ws.waitingForDevice) return 'Conectado al servidor — esperando guante';
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
