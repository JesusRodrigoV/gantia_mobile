import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_model.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../utils/error_message_mapper.dart';
import '../utils/snackbar_helper.dart';
import 'gantia_button.dart';
import 'history_action_card.dart';

class HistoryActionsTab extends ConsumerStatefulWidget {
  const HistoryActionsTab({super.key});

  @override
  ConsumerState<HistoryActionsTab> createState() => _HistoryActionsTabState();
}

class _HistoryActionsTabState extends ConsumerState<HistoryActionsTab> {
  static const int _pageSize = 50;
  final List<HistoryActionEntry> _entries = [];
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
        limit: _pageSize, offset: _offset,
      );
      if (!mounted) return;
      setState(() {
        _entries.addAll(result);
        _allLoaded = result.length < _pageSize;
        _offset += result.length;
      });
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, mapErrorToMessage(e));
      }
    }
  }

  Future<void> _refresh() async {
    try {
      final result = await ref.read(historyServiceProvider).getActionsHistory(
        limit: _pageSize, offset: 0,
      );
      if (!mounted) return;
      setState(() {
        _entries..clear()..addAll(result);
        _allLoaded = result.length < _pageSize;
        _offset = result.length;
      });
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, mapErrorToMessage(e));
      }
    }
  }

  void _loadMore() {
    if (!_allLoaded) _fetch();
  }

  @override
  Widget build(BuildContext context) {
    final svc = ref.watch(historyServiceProvider);
    if (svc.isLoading && _entries.isEmpty) return _buildLoading();
    if (_entries.isEmpty && svc.error != null) return _buildError(svc.error!, _refresh);
    if (_entries.isEmpty) return _buildEmpty();
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        children: [
          const SizedBox(height: Spacing.xs),
          ..._entries.map((e) => HistoryActionCard(entry: e)),
          if (!_allLoaded && !svc.isLoading)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.sm, bottom: Spacing.xxl),
              child: Center(
                child: GantiaButton(label: 'Cargar más', icon: Icons.expand_more, onPressed: _loadMore),
              ),
            )
          else
            const SizedBox(height: Spacing.xxl),
        ],
      ),
    );
  }



  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      children: List.generate(8, (_) => Container(
        margin: const EdgeInsets.only(bottom: Spacing.md),
        decoration: BoxDecoration(color: context.surface0, borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 14, width: 140, decoration: BoxDecoration(color: context.surface100, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: Spacing.sm),
          Container(height: 12, width: double.infinity, decoration: BoxDecoration(color: context.surface100, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: Spacing.xxs),
          Container(height: 12, width: 180, decoration: BoxDecoration(color: context.surface100, borderRadius: BorderRadius.circular(4))),
        ]),
      )),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.history_toggle_off, size: 48, color: context.surface500),
          const SizedBox(height: Spacing.md),
          Text('Sin acciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.surface700)),
          const SizedBox(height: Spacing.xs),
          Text('Todavía no hay acciones registradas.', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: context.surface500)),
        ]),
      ),
    );
  }

  Widget _buildError(String err, VoidCallback onRetry) {
    dev.log('[HistoryActionsTab] $err');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off, size: 48, color: AppColors.amber600),
          const SizedBox(height: Spacing.md),
          Text(
            'No se pudieron cargar las acciones',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.surface700),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            'Verificá la conexión e intentá de nuevo.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: context.surface500),
          ),
          const SizedBox(height: Spacing.lg),
          GantiaButton(label: 'Reintentar', icon: Icons.refresh, onPressed: onRetry),
        ]),
      ),
    );
  }
}
