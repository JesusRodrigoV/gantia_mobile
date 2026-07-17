import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import 'settings_card.dart';

class BtScannerSection extends ConsumerWidget {
  const BtScannerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bt = ref.watch(btServiceProvider);

    return SettingsCard(
      icon: Icons.bluetooth,
      title: 'Dispositivo Bluetooth',
      description: bt.isConnected
          ? 'Conectado a ${bt.deviceName ?? bt.deviceAddress ?? 'audio'}'
          : 'Conectá un parlante o auricular desde Ajustes de Android',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: bt.isConnected
                  ? AppColors.primary500.withAlpha(15)
                  : context.surface100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  bt.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  size: 24,
                  color: bt.isConnected ? AppColors.primary500 : context.surface400,
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bt.isConnected
                            ? (bt.deviceName ?? bt.deviceAddress ?? 'Audio')
                            : 'Sin dispositivo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: bt.isConnected ? context.surface800 : context.surface500,
                        ),
                      ),
                      Text(
                        bt.isConnected ? 'Conectado' : 'Desconectado',
                        style: TextStyle(
                          fontSize: 11,
                          color: bt.isConnected ? AppColors.primary500 : context.surface400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (bt.isConnected)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'El dispositivo se empareja desde los Ajustes del teléfono. '
            'Al hacer un gesto de control multimedia, Gantia lo envía automáticamente '
            'al parlante o auricular conectado.',
            style: TextStyle(fontSize: 11, color: context.surface400),
          ),
        ],
      ),
    );
  }
}
