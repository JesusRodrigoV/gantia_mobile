import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/spacing.dart';
import 'gantia_button.dart';
import 'settings_card.dart';

class BtScannerSection extends ConsumerWidget {
  const BtScannerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final btService = ref.watch(btServiceProvider);

    return SettingsCard(
      icon: Icons.bluetooth,
      title: 'Parlante Bluetooth',
      description: 'Conectá un parlante Bluetooth para control de audio',
      child: Column(
        children: [
          if (btService.isConnected)
            Container(
              padding: const EdgeInsets.all(Spacing.sm),
              margin: const EdgeInsets.only(bottom: Spacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary500.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bluetooth_connected, color: AppColors.primary500, size: 20),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      btService.connectedDevice ?? 'Conectado',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary600),
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
          if (btService.error != null)
            Container(
              margin: const EdgeInsets.only(bottom: Spacing.sm),
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: AppColors.red500.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 16, color: AppColors.red500),
                  const SizedBox(width: Spacing.xs),
                  Expanded(child: Text(btService.error!,
                    style: const TextStyle(fontSize: 12, color: AppColors.red500))),
                  GestureDetector(
                    onTap: () => btService.clearError(),
                    child: const Icon(Icons.close, size: 16, color: AppColors.red500),
                  ),
                ],
              ),
            ),
          GantiaButton(
            label: btService.isScanning ? 'Escaneando...' : 'Escanear dispositivos',
            icon: Icons.search,
            isLoading: btService.isScanning,
            onPressed: btService.isScanning ? null : () => btService.scanDevices(),
          ),
          if (btService.availableDevices.isNotEmpty) ...[
            const SizedBox(height: Spacing.xs),
            ...btService.availableDevices.map((d) => ListTile(
              dense: true,
              title: Text(d, style: const TextStyle(fontSize: 13)),
              trailing: GantiaButton(label: 'Conectar', onPressed: () => btService.connect(d)),
            )),
          ],
        ],
      ),
    );
  }
}
