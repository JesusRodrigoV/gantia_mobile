import 'package:flutter/material.dart';
import '../services/glove_state.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import 'neuromorphic_card.dart';
import 'status_dot.dart';

class HomeConnectionCard extends StatelessWidget {
  final GloveState gloveState;

  const HomeConnectionCard({super.key, required this.gloveState});

  @override
  Widget build(BuildContext context) {
    final statusText = _statusLabel();

    return NeuromorphicCard(
      showAccentLine: false,
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        children: [
          Row(
            children: [
              StatusDot(status: gloveState.connectionStatus, flowing: gloveState.dataFlowing),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(statusText,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.surface800)),
                    if (gloveState.telemetry != null)
                      Text('Datos recibiendo',
                        style: TextStyle(fontSize: 12, color: context.surface600)),
                  ],
                ),
              ),
              if (gloveState.dataFlowing)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.xs, vertical: Spacing.xxs),
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flash_on, size: 12, color: AppColors.primary500),
                      SizedBox(width: Spacing.xxs),
                      Text('ACTIVO',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary600)),
                    ],
                  ),
                ),
            ],
          ),
          if (gloveState.waitingForDevice) ...[
            const SizedBox(height: Spacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(vertical: Spacing.xs, horizontal: Spacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary500.withAlpha(10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: Spacing.xs),
                  Text('Conectado al servidor — esperando guante...',
                    style: TextStyle(fontSize: 12, color: context.surface600)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel() {
    switch (gloveState.connectionStatus) {
      case ConnectionStatus.connected:
        if (gloveState.dataFlowing) return 'Guante conectado — recibiendo datos';
        if (gloveState.waitingForDevice) return 'Conectado al servidor — esperando guante';
        return 'Conectado — sin datos';
      case ConnectionStatus.connecting:
        return 'Conectando al servidor...';
      case ConnectionStatus.reconnecting:
        return 'Reconectando (${gloveState.retryAttempt}/${gloveState.maxRetries})...';
      case ConnectionStatus.disconnected:
        return 'Sin conexión';
      case ConnectionStatus.error:
        return 'Error de conexión';
    }
  }
}
