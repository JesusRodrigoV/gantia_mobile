import 'package:flutter/material.dart';
import '../services/glove_state.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import 'neuromorphic_card.dart';

class HomeDeviceInfo extends StatelessWidget {
  final GloveState gloveState;
  final bool btConnected;
  final String? btDeviceName;

  const HomeDeviceInfo({
    super.key,
    required this.gloveState,
    required this.btConnected,
    this.btDeviceName,
  });

  @override
  Widget build(BuildContext context) {
    return NeuromorphicCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DISPOSITIVOS',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.primary600)),
          const SizedBox(height: Spacing.sm),
          _deviceRow(context, Icons.back_hand, 'Guante', gloveState.connectionStatus == ConnectionStatus.connected),
          const SizedBox(height: 8),
          _deviceRow(context, Icons.bluetooth_audio, 'Parlante BT', btConnected, detail: btDeviceName),
        ],
      ),
    );
  }

  Widget _deviceRow(BuildContext context, IconData icon, String label, bool connected, {String? detail}) {
    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(color: context.surface100, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          _dot(connected),
          const SizedBox(width: Spacing.sm),
          Icon(icon, size: 20, color: AppColors.primary500),
          const SizedBox(width: Spacing.xs),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.surface800)),
          const Spacer(),
          Text(connected ? 'Conectado' : 'Desconectado',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: connected ? AppColors.primary500 : context.surface500)),
        ],
      ),
    );
  }

  Widget _dot(bool active) {
    return Container(
      width: 8, height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.primary500 : AppColors.red500,
      ),
    );
  }
}

class HomeHealthCard extends StatelessWidget {
  final GloveTelemetry telemetry;

  const HomeHealthCard({super.key, required this.telemetry});

  @override
  Widget build(BuildContext context) {
    final t = telemetry;
    final rssi = t.rssi ?? -100;
    final temp = t.tempMpu ?? 0;
    final bars = rssi >= -50 ? 5 : rssi >= -60 ? 4 : rssi >= -70 ? 3 : rssi >= -80 ? 2 : 1;
    final totalSec = (t.uptimeMs ?? 0) ~/ 1000;
    final hrs = totalSec ~/ 3600;
    final min = (totalSec % 3600) ~/ 60;
    final sec = totalSec % 60;
    final uptimeStr = hrs > 0 ? '${hrs}h ${min}m' : min > 0 ? '${min}m ${sec}s' : '${sec}s';

    return NeuromorphicCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SALUD DEL GUANTE',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.primary600)),
          const SizedBox(height: Spacing.sm),
          Row(children: [
            _badge(context, Icons.wifi, '$rssi dBm', 'WiFi'),
            const SizedBox(width: Spacing.sm),
            _badge(context, Icons.thermostat, '${temp.toStringAsFixed(1)}°C', 'Temp'),
            const SizedBox(width: Spacing.sm),
            _badge(context, Icons.timer, uptimeStr, 'Activo'),
          ]),
          const SizedBox(height: Spacing.xs),
          Row(children: List.generate(5, (i) {
            final active = i < bars;
            return Container(
              width: 8, height: 4.0 + i * 3.0,
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(
                color: active ? AppColors.primary500 : context.surface400,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
              ),
            );
          })),
        ],
      ),
    );
  }

  Widget _badge(BuildContext context, IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(Spacing.sm),
        decoration: BoxDecoration(color: context.surface100, borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Icon(icon, size: 18, color: AppColors.primary500),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.surface800)),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: context.surface500)),
        ]),
      ),
    );
  }
}
