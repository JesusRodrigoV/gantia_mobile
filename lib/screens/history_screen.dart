import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../models/history_model.dart';
import '../models/action_message.dart';
import '../widgets/gantia_button.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  static const int _pageSize = 50;

  final List<HistoryActionEntry> _allEntries = [];
  int _offset = 0;
  bool _allLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetch);
  }

  Future<void> _fetch() async {
    try {
      final result = await ref.read(historyServiceProvider).getActionsHistory(
        limit: _pageSize,
        offset: _offset,
      );
      if (!mounted) return;
      setState(() {
        _allEntries.addAll(result);
        _allLoaded = result.length < _pageSize;
        _offset += result.length;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  Future<void> _refresh() async {
    try {
      final result = await ref.read(historyServiceProvider).getActionsHistory(
        limit: _pageSize,
        offset: 0,
      );
      if (!mounted) return;
      setState(() {
        _allEntries
          ..clear()
          ..addAll(result);
        _allLoaded = result.length < _pageSize;
        _offset = result.length;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  void _loadMore() {
    if (!_allLoaded) _fetch();
  }

  String _formatTimestamp(int seconds) {
    final date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    if (diff.inDays < 7) return '${diff.inDays}d atrás';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sent':
      case 'success':
        return AppColors.primary500;
      case 'error':
      case 'failed':
        return AppColors.red500;
      case 'pending':
        return AppColors.amber500;
      default:
        return context.surface500;
    }
  }

  IconData _targetIcon(String target) {
    switch (target.toLowerCase()) {
      case 'pico_w':
        return Icons.memory;
      case 'mobile':
        return Icons.phone_android;
      case 'agent':
        return Icons.smart_toy;
      default:
        return Icons.devices;
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyService = ref.watch(historyServiceProvider);
    final isLoading = historyService.isLoading;
    final error = historyService.error;
    final isEmpty = _allEntries.isEmpty && !isLoading && error == null;
    final hasMore = !_allLoaded && !isLoading;

    return Scaffold(
      backgroundColor: context.surface50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.md, Spacing.md, Spacing.md, Spacing.xs,
              ),
              child: Row(
                children: [
                  const Icon(Icons.history, color: AppColors.primary500, size: 28),
                  const SizedBox(width: Spacing.xs),
                  const Text(
                    'Historial',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.surfaceLight700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildContent(_allEntries, isLoading, error, isEmpty, hasMore),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    List<HistoryActionEntry> entries,
    bool isLoading,
    String? error,
    bool isEmpty,
    bool hasMore,
  ) {
    if (isLoading && entries.isEmpty) {
      return _buildLoadingSkeleton();
    }

    if (error != null && entries.isEmpty) {
      return _buildErrorState(error);
    }

    if (isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        children: [
          ...entries.map((entry) => _buildEntryCard(entry)),
          if (hasMore)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.sm, bottom: Spacing.xxl),
              child: Center(
                child: GantiaButton(
                  label: 'Cargar más',
                  icon: Icons.expand_more,
                  onPressed: _loadMore,
                ),
              ),
            )
          else
            const SizedBox(height: Spacing.xxl),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      children: List.generate(
        8,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: Spacing.md),
          decoration: BoxDecoration(
            color: context.surface0,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 140,
                  decoration: BoxDecoration(
                    color: context.surface100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.surface100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: Spacing.xxs),
                Container(
                  height: 12,
                  width: 180,
                  decoration: BoxDecoration(
                    color: context.surface100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.red500),
            const SizedBox(height: Spacing.md),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.surfaceLight600,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            GantiaButton(
              label: 'Reintentar',
              icon: Icons.refresh,
              onPressed: () {
                _offset = 0;
                _allEntries.clear();
                _allLoaded = false;
                _fetch();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_toggle_off, size: 48, color: AppColors.surfaceLight400),
            const SizedBox(height: Spacing.md),
            const Text(
              'Sin acciones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.surfaceLight600,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            const Text(
              'Todavía no hay acciones registradas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.surfaceLight400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(HistoryActionEntry entry) {
    final actionLabel = getActionLabel(entry.action);
    final formattedTime = _formatTimestamp(entry.timestamp);
    final statusColor = _statusColor(entry.status);
    final targetIcon = _targetIcon(entry.target);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      decoration: BoxDecoration(
        color: context.surface0,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.surface100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, size: 16, color: AppColors.primary500),
                const SizedBox(width: Spacing.xxs),
                Expanded(
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.surfaceLight800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    entry.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                Icon(targetIcon, size: 13, color: context.surface500),
                const SizedBox(width: 4),
                Text(
                  entry.target,
                  style: TextStyle(fontSize: 12, color: context.surface500),
                ),
                if (entry.actionValue != null && entry.actionValue!.isNotEmpty) ...[
                  const SizedBox(width: Spacing.sm),
                  Container(width: 1, height: 12, color: context.surface200),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      entry.actionValue!,
                      style: TextStyle(fontSize: 12, color: context.surface500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else
                  const Spacer(),
                const SizedBox(width: Spacing.sm),
                Icon(Icons.access_time, size: 12, color: context.surface400),
                const SizedBox(width: 3),
                Text(
                  formattedTime,
                  style: TextStyle(fontSize: 11, color: context.surface400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
