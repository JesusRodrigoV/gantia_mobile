import 'package:flutter/material.dart';
import '../models/smart_home_device.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import 'gantia_button.dart';

class SmartSceneCard extends StatelessWidget {
  final Scene scene;
  final VoidCallback onApply;
  final VoidCallback onDelete;

  const SmartSceneCard({
    super.key,
    required this.scene,
    required this.onApply,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: context.surface100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.view_quilt, size: 20, color: AppColors.primary500),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scene.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.surface800,
                  ),
                ),
                Text(
                  '${scene.devices.where((d) => d.isOn).length}/${scene.devices.length} encendidas',
                  style: TextStyle(fontSize: 11, color: context.surface600),
                ),
              ],
            ),
          ),
          GantiaButton(
            label: 'Aplicar',
            icon: Icons.play_arrow,
            variant: GantiaButtonVariant.primary,
            onPressed: onApply,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          ),
          const SizedBox(width: Spacing.xxs),
          GantiaButton(
            label: '',
            icon: Icons.delete,
            variant: GantiaButtonVariant.danger,
            onPressed: onDelete,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ],
      ),
    );
  }
}
