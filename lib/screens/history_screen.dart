import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../widgets/history_actions_tab.dart';
import '../widgets/history_readings_tab.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surface50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, 0),
              child: Row(
                children: [
                  const Icon(Icons.history, color: AppColors.primary500, size: 28),
                  const SizedBox(width: Spacing.xs),
                  Text('Historial',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: context.surface800)),
                ],
              ),
            ),
            TabBar(
              controller: _tabCtrl,
              indicatorColor: AppColors.primary500,
              labelColor: AppColors.primary500,
              unselectedLabelColor: context.surface500,
              tabs: const [
                Tab(text: 'ACCIONES'),
                Tab(text: 'LECTURAS'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: const [
                  HistoryActionsTab(),
                  HistoryReadingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
