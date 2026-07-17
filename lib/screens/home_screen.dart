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
import '../models/action_message.dart';
import '../widgets/sensor_chart.dart';
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
                      _chartCard(SensorType.accelerometer, gloveState),
                      const SizedBox(height: Spacing.md),
                      _chartCard(SensorType.gyroscope, gloveState),
                      const SizedBox(height: Spacing.md),
                      _chartCard(SensorType.flexion, gloveState),
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

  Widget _chartCard(SensorType type, GloveState gloveState) {
    return NeuromorphicCard(
      showAccentLine: false,
      padding: const EdgeInsets.all(Spacing.md),
      child: SensorChart(
        sensorType: type,
        lines: _extractLiveLines(type, gloveState.telemetryBuffer),
        showTitle: true,
        animated: true,
      ),
    );
  }

  List<List<double>> _extractLiveLines(SensorType type, List<GloveTelemetry> data) {
    return switch (type) {
      SensorType.accelerometer => [
        data.map((e) => e.accelX).toList(),
        data.map((e) => e.accelY).toList(),
        data.map((e) => e.accelZ).toList(),
      ],
      SensorType.gyroscope => [
        data.map((e) => e.gyroX).toList(),
        data.map((e) => e.gyroY).toList(),
        data.map((e) => e.gyroZ).toList(),
      ],
      SensorType.flexion => [
        data.map((e) => e.flexIndex.toDouble()).toList(),
        data.map((e) => e.flexMiddle.toDouble()).toList(),
      ],
    };
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
