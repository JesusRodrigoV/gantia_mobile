import 'package:flutter/material.dart';
import '../models/action_message.dart';
import '../models/history_model.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';

class HistoryActionCard extends StatelessWidget {
  final HistoryActionEntry entry;

  const HistoryActionCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final actionLabel = getActionLabel(entry.action);
    final formattedTime = formatTimestamp(entry.timestamp);
    final color = statusColor(entry.status, context);
    final icon = targetIcon(entry.target);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      decoration: BoxDecoration(
        color: context.surface0,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.surface100),
      ),
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.bolt, size: 16, color: AppColors.primary500),
            const SizedBox(width: Spacing.xxs),
            Expanded(child: Text(actionLabel,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.surface900))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(6)),
              child: Text(entry.status,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            ),
          ]),
          const SizedBox(height: Spacing.sm),
          Row(children: [
            Icon(icon, size: 13, color: context.surface500),
            const SizedBox(width: 4),
            Text(entry.target, style: TextStyle(fontSize: 12, color: context.surface500)),
            if (entry.actionValue != null && entry.actionValue!.isNotEmpty) ...[
              const SizedBox(width: Spacing.sm),
              Container(width: 1, height: 12, color: context.surface200),
              const SizedBox(width: Spacing.sm),
              Expanded(child: Text(entry.actionValue!,
                style: TextStyle(fontSize: 12, color: context.surface500), overflow: TextOverflow.ellipsis)),
            ] else const Spacer(),
            Icon(Icons.access_time, size: 12, color: context.surface400),
            const SizedBox(width: 3),
            Text(formattedTime, style: TextStyle(fontSize: 11, color: context.surface400)),
          ]),
        ],
      ),
    );
  }

  static Color statusColor(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'sent': case 'success': return AppColors.primary500;
      case 'error': case 'failed': return AppColors.red500;
      case 'pending': return AppColors.amber500;
      default: return context.surface500;
    }
  }

  static IconData targetIcon(String target) {
    switch (target.toLowerCase()) {
      case 'pico_w': return Icons.memory;
      case 'mobile': return Icons.phone_android;
      case 'agent': return Icons.smart_toy;
      default: return Icons.devices;
    }
  }

  static String formatTimestamp(int seconds) {
    final date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    if (diff.inDays < 7) return '${diff.inDays}d atrás';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
