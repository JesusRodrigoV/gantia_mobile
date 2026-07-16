import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart' hide ActionLog;
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../widgets/action_log.dart';
import '../widgets/gantia_header.dart';
import '../widgets/gesture_flash.dart';
import '../widgets/home_connection_card.dart';
import '../widgets/home_health_card.dart';
import '../widgets/live_chart.dart';
import '../widgets/neuromorphic_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _scrolled = false;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    final s = _scrollCtrl.offset > 20;
    if (s != _scrolled) setState(() => _scrolled = s);
  }

  @override
  Widget build(BuildContext context) {
    final gloveState = ref.watch(gloveStateProvider);
    final bt = ref.watch(btServiceProvider);

    return Scaffold(
      backgroundColor: context.surface50,
      body: SafeArea(
        child: Column(
          children: [
            GantiaHeader(
              scrolled: _scrolled,
              onLogout: () async {
                ref.read(wsClientProvider).disconnect();
                await ref.read(authServiceProvider).logout();
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  children: [
                    Center(child: GestureFlash(event: gloveState.gestureDetected)),
                    const SizedBox(height: Spacing.md),
                    HomeConnectionCard(gloveState: gloveState),
                    const SizedBox(height: Spacing.md),
                    if (gloveState.dataFlowing && gloveState.telemetryBuffer.length >= 2) ...[
                      _chartCard(LiveChartType.accelerometer, 'Acelerómetro', gloveState),
                      const SizedBox(height: Spacing.md),
                      _chartCard(LiveChartType.gyroscope, 'Giroscopio', gloveState),
                      const SizedBox(height: Spacing.md),
                      _chartCard(LiveChartType.flexion, 'Flexión', gloveState),
                      const SizedBox(height: Spacing.md),
                    ],
                    _actionLogCard(),
                    const SizedBox(height: Spacing.md),
                    HomeDeviceInfo(
                      gloveState: gloveState,
                      btConnected: bt.isConnected,
                      btDeviceName: bt.connectedDevice,
                    ),
                    if (gloveState.telemetry?.hasHealth == true) ...[
                      const SizedBox(height: Spacing.md),
                      HomeHealthCard(telemetry: gloveState.telemetry!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartCard(LiveChartType type, String label, GloveState gloveState) {
    return NeuromorphicCard(
      showAccentLine: false,
      padding: const EdgeInsets.all(Spacing.md),
      child: LiveChart(type: type, data: gloveState.telemetryBuffer),
    );
  }

  Widget _actionLogCard() {
    final actions = ref.watch(actionLogProvider).recentActions;
    return NeuromorphicCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ACCIONES RECIENTES',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.primary600)),
          const SizedBox(height: Spacing.sm),
          ActionLog(actions: actions),
        ],
      ),
    );
  }
}
