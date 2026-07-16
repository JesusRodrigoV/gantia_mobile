import 'package:flutter/material.dart';
import '../models/action_message.dart';
import '../models/gesture_config_model.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import 'neuromorphic_card.dart';

class GestureConfigRow extends StatelessWidget {
  final GestureConfig config;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GestureConfigRow({
    super.key,
    required this.config,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return NeuromorphicCard(
      showAccentLine: false,
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.movement == 'COMPOSITE'
                      ? 'Compuesto: ${config.actionKey}'
                      : '${getMovementLabel(config.movement)} / ${getOrientationLabel(config.orientation)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.surface700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Índice: ${getFlexStateLabel(config.indexState)}   '
                  'Medio: ${getFlexStateLabel(config.middleState)}',
                  style: TextStyle(fontSize: 11, color: context.surface500),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary500.withAlpha(20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        config.movement == 'COMPOSITE'
                            ? 'COMPUESTO'
                            : getActionLabel(config.actionKey),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: config.movement == 'COMPOSITE'
                              ? AppColors.amber600
                              : AppColors.primary600,
                        ),
                      ),
                    ),
                    if (config.actionValue != null &&
                        config.actionValue!.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Text(
                        ': ${config.actionValue}',
                        style: TextStyle(
                          fontSize: 10,
                          color: context.surface500,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      getContextLabel(config.context),
                      style: TextStyle(
                        fontSize: 10,
                        color: context.surface400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.xs),
          _actionButton(Icons.edit, AppColors.primary500, onEdit),
          const SizedBox(width: 4),
          _actionButton(Icons.delete, AppColors.red500, onDelete),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
