import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_model.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../utils/error_message_mapper.dart';
import 'gantia_button.dart';
import 'sensor_chart.dart';

class HistoryReadingsTab extends ConsumerStatefulWidget {
  const HistoryReadingsTab({super.key});

  @override
  ConsumerState<HistoryReadingsTab> createState() => _HistoryReadingsTabState();
}

class _HistoryReadingsTabState extends ConsumerState<HistoryReadingsTab> {
  List<HistoryReading> _readings = [];
  bool _loading = false;
  String? _error;
  SensorType _chartType = SensorType.accelerometer;
  static const int _limit = 200;

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetch);
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await ref.read(historyServiceProvider).getReadingsHistory(
        since: DateTime.now().subtract(const Duration(hours: 6)),
        limit: _limit,
      );
      if (!mounted) return;
      setState(() { _readings = result; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = mapErrorToMessage(e); });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _readings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _readings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.red500),
            const SizedBox(height: Spacing.md),
            Text(_error!, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: context.surface700)),
            const SizedBox(height: Spacing.lg),
            GantiaButton(label: 'Reintentar', icon: Icons.refresh, onPressed: _fetch),
          ]),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetch,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        children: [
          const SizedBox(height: Spacing.xs),
          Row(children: [
            _chip(SensorType.accelerometer, 'Acelerómetro'),
            const SizedBox(width: Spacing.xs),
            _chip(SensorType.gyroscope, 'Giroscopio'),
            const SizedBox(width: Spacing.xs),
            _chip(SensorType.flexion, 'Flexión'),
          ]),
          const SizedBox(height: Spacing.sm),
          Row(children: [
            GantiaButton(label: 'Actualizar', icon: Icons.refresh, onPressed: _fetch),
          ]),
          const SizedBox(height: Spacing.sm),
          if (_readings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.xxxl),
              child: Column(children: [
                Icon(Icons.show_chart, size: 48, color: context.surface500),
                const SizedBox(height: Spacing.md),
                Text('Sin lecturas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.surface700)),
                const SizedBox(height: Spacing.xs),
                Text('Presioná "Actualizar" para cargar datos.', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: context.surface500)),
              ]),
            )
          else ...[
            SensorChart(
              sensorType: _chartType,
              lines: _extractLines(_readings, _chartType),
              showTimeAxis: true,
              height: 220,
            ),
            const SizedBox(height: Spacing.md),
            ..._readings.take(50).map(_buildRow),
            const SizedBox(height: Spacing.xxl),
          ],
        ],
      ),
    );
  }

  List<List<double>> _extractLines(List<HistoryReading> readings, SensorType type) {
    return switch (type) {
      SensorType.accelerometer => [
        readings.map((r) => r.accelX).toList(),
        readings.map((r) => r.accelY).toList(),
        readings.map((r) => r.accelZ).toList(),
      ],
      SensorType.gyroscope => [
        readings.map((r) => r.gyroX).toList(),
        readings.map((r) => r.gyroY).toList(),
        readings.map((r) => r.gyroZ).toList(),
      ],
      SensorType.flexion => [
        readings.map((r) => r.flexIndex).toList(),
        readings.map((r) => r.flexMiddle).toList(),
      ],
    };
  }

  Widget _chip(SensorType type, String label) {
    final selected = _chartType == type;
    return GestureDetector(
      onTap: () => setState(() => _chartType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary500 : context.surface100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: selected ? Colors.white : context.surface500)),
      ),
    );
  }

  Widget _buildRow(HistoryReading r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
      decoration: BoxDecoration(color: context.surface0, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Text('${r.timestamp.hour}:${r.timestamp.minute.toString().padLeft(2, '0')}:${r.timestamp.second.toString().padLeft(2, '0')}',
          style: TextStyle(fontSize: 11, color: context.surface500)),
        const SizedBox(width: Spacing.sm),
        Expanded(child: Text(
          'A:${r.accelX.toStringAsFixed(1)},${r.accelY.toStringAsFixed(1)},${r.accelZ.toStringAsFixed(1)}  '
          'G:${r.gyroX.toStringAsFixed(0)},${r.gyroY.toStringAsFixed(0)},${r.gyroZ.toStringAsFixed(0)}  '
          'F:${r.flexIndex.toStringAsFixed(0)}/${r.flexMiddle.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 10, color: context.surface500, fontFamily: 'monospace'),
          overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}
