import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/history_model.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';

enum ReadingsChartType { accelerometer, gyroscope, flexion }

class ReadingsChart extends StatelessWidget {
  final List<HistoryReading> data;
  final ReadingsChartType type;

  const ReadingsChart({super.key, required this.data, required this.type});

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Se necesitan al menos 2 lecturas',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.surfaceLight400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    final sorted = List<HistoryReading>.from(data)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return SizedBox(
      height: 220,
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: context.surface200,
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      getTitlesWidget: (v, _) => Text(
                        v.toStringAsFixed(v.abs() > 10 ? 0 : 1),
                        style: TextStyle(
                          fontSize: 9,
                          color: context.surface400,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: _intervalForLength(sorted.length),
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt().clamp(0, sorted.length - 1);
                        final t = sorted[idx].timestamp;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${t.hour}:${t.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 9,
                              color: context.surface400,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (sorted.length - 1).toDouble(),
                minY: _minY,
                maxY: _maxY,
                lineBarsData: _buildLines(sorted),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                      return LineTooltipItem(
                        s.y.toStringAsFixed(1),
                        TextStyle(
                          color: _colors[s.barIndex % _colors.length],
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Row(
            children: _legendLabels.asMap().entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _colors[e.key],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 10,
                        color: context.surface500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  double _intervalForLength(int length) {
    if (length <= 5) return 1;
    return (length / 5).ceilToDouble();
  }

  List<String> get _legendLabels {
    switch (type) {
      case ReadingsChartType.accelerometer:
        return ['X', 'Y', 'Z'];
      case ReadingsChartType.gyroscope:
        return ['X', 'Y', 'Z'];
      case ReadingsChartType.flexion:
        return ['Índice', 'Medio'];
    }
  }

  List<Color> get _colors {
    switch (type) {
      case ReadingsChartType.accelerometer:
        return [AppColors.cyan500, AppColors.primary500, AppColors.warning500];
      case ReadingsChartType.gyroscope:
        return [AppColors.purple500, AppColors.primary500, AppColors.warning500];
      case ReadingsChartType.flexion:
        return [AppColors.primary500, AppColors.warning500];
    }
  }

  double get _minY {
    switch (type) {
      case ReadingsChartType.accelerometer:
        return -2.5;
      case ReadingsChartType.gyroscope:
        return -250;
      case ReadingsChartType.flexion:
        return 0;
    }
  }

  double get _maxY {
    switch (type) {
      case ReadingsChartType.accelerometer:
        return 2.5;
      case ReadingsChartType.gyroscope:
        return 250;
      case ReadingsChartType.flexion:
        return 100;
    }
  }

  List<LineChartBarData> _buildLines(List<HistoryReading> sorted) {
    switch (type) {
      case ReadingsChartType.accelerometer:
        return [
          _buildSpots(sorted, (r) => r.accelX, _colors[0]),
          _buildSpots(sorted, (r) => r.accelY, _colors[1]),
          _buildSpots(sorted, (r) => r.accelZ, _colors[2]),
        ];
      case ReadingsChartType.gyroscope:
        return [
          _buildSpots(sorted, (r) => r.gyroX, _colors[0]),
          _buildSpots(sorted, (r) => r.gyroY, _colors[1]),
          _buildSpots(sorted, (r) => r.gyroZ, _colors[2]),
        ];
      case ReadingsChartType.flexion:
        return [
          _buildSpots(sorted, (r) => r.flexIndex, _colors[0]),
          _buildSpots(sorted, (r) => r.flexMiddle, _colors[1]),
        ];
    }
  }

  LineChartBarData _buildSpots(
    List<HistoryReading> sorted,
    double Function(HistoryReading) getValue,
    Color color,
  ) {
    final spots = <FlSpot>[];
    for (var i = 0; i < sorted.length; i++) {
      spots.add(FlSpot(i.toDouble(), getValue(sorted[i])));
    }
    return LineChartBarData(
      spots: spots,
      color: color,
      barWidth: 1.5,
      isCurved: true,
      curveSmoothness: 0.2,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withAlpha(15),
      ),
    );
  }
}
