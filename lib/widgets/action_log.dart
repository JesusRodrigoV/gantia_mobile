import 'package:flutter/material.dart';
import '../models/action_message.dart';
import '../theme/app_colors.dart';

class ActionLog extends StatelessWidget {
  final List<ActionEvent> actions;

  const ActionLog({super.key, required this.actions});

  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Sin acciones registradas',
            style: TextStyle(
              color: AppColors.surfaceLight400,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length > 30 ? 30 : actions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final action = actions[index];
        final isFirst = index == 0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: isFirst
                ? AppColors.primary500.withAlpha(15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(
                _iconForAction(action.action),
                size: 18,
                color: isFirst ? AppColors.primary500 : AppColors.surfaceLight400,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  getActionLabel(action.action),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isFirst ? FontWeight.w700 : FontWeight.w500,
                    color: AppColors.surfaceLight700,
                  ),
                ),
              ),
              if (action.actionValue != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${action.actionValue}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.surfaceLight600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  IconData _iconForAction(String action) {
    switch (action) {
      case 'volume_up':
      case 'volume_down':
        return Icons.volume_up;
      case 'mute':
        return Icons.volume_off;
      case 'play_pause':
        return Icons.play_arrow;
      case 'next':
        return Icons.skip_next;
      case 'prev':
        return Icons.skip_previous;
      case 'mouse_mode':
        return Icons.mouse;
      case 'light_on':
      case 'light_off':
        return Icons.lightbulb;
      case 'brightness_up':
      case 'brightness_down':
        return Icons.brightness_6;
      case 'next_slide':
        return Icons.navigate_next;
      case 'prev_slide':
        return Icons.navigate_before;
      default:
        return Icons.flash_on;
    }
  }
}
