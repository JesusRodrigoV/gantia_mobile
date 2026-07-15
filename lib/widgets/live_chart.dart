import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/action_message.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';

enum LiveChartType { accelerometer, gyroscope, flexion }

class LiveChart extends StatelessWidget {
  final LiveChartType type;
  final List<GloveTelemetry> data;

  const LiveChart({super.key, required this.type, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.primary600,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        SizedBox(
          height: 140,
          child: data.length < 2
              ? const Center(
                  child: Text(
                    'Esperando datos...',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.surfaceLight400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : LineChart(
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
                            v.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 9,
                              color: context.surface400,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
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
                    maxX: (data.length - 1).toDouble().clamp(1, double.infinity),
                    minY: _minY,
                    maxY: _maxY,
                    lineBarsData: _spots,
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
                  duration: const Duration(milliseconds: 150),
                ),
        ),
        const SizedBox(height: Spacing.xxs),
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
    );
  }

  String get _title {
    switch (type) {
      case LiveChartType.accelerometer:
        return 'ACELERÓMETRO';
      case LiveChartType.gyroscope:
        return 'GIROSCOPIO';
      case LiveChartType.flexion:
        return 'FLEXIÓN';
    }
  }

  List<String> get _legendLabels {
    switch (type) {
      case LiveChartType.accelerometer:
        return ['X', 'Y', 'Z'];
      case LiveChartType.gyroscope:
        return ['X', 'Y', 'Z'];
      case LiveChartType.flexion:
        return ['Índice', 'Medio'];
    }
  }

  List<Color> get _colors {
    switch (type) {
      case LiveChartType.accelerometer:
        return [AppColors.cyan500, AppColors.primary500, AppColors.warning500];
      case LiveChartType.gyroscope:
        return [AppColors.purple500, AppColors.primary500, AppColors.warning500];
      case LiveChartType.flexion:
        return [AppColors.primary500, AppColors.warning500];
    }
  }

  double get _minY {
    switch (type) {
      case LiveChartType.accelerometer:
        return -2.5;
      case LiveChartType.gyroscope:
        return -250;
      case LiveChartType.flexion:
        return 0;
    }
  }

  double get _maxY {
    switch (type) {
      case LiveChartType.accelerometer:
        return 2.5;
      case LiveChartType.gyroscope:
        return 250;
      case LiveChartType.flexion:
        return 100;
    }
  }

  List<LineChartBarData> get _spots {
    switch (type) {
      case LiveChartType.accelerometer:
        return [
          _buildLine(data.map((e) => e.accelX).toList(), _colors[0]),
          _buildLine(data.map((e) => e.accelY).toList(), _colors[1]),
          _buildLine(data.map((e) => e.accelZ).toList(), _colors[2]),
        ];
      case LiveChartType.gyroscope:
        return [
          _buildLine(data.map((e) => e.gyroX).toList(), _colors[0]),
          _buildLine(data.map((e) => e.gyroY).toList(), _colors[1]),
          _buildLine(data.map((e) => e.gyroZ).toList(), _colors[2]),
        ];
      case LiveChartType.flexion:
        return [
          _buildLine(data.map((e) => e.flexIndex.toDouble()).toList(), _colors[0]),
          _buildLine(data.map((e) => e.flexMiddle.toDouble()).toList(), _colors[1]),
        ];
    }
  }

  LineChartBarData _buildLine(List<double> values, Color color) {
    final spots = <FlSpot>[];
    for (var i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i]));
    }
    return LineChartBarData(
      spots: spots,
      color: color,
      barWidth: 1.8,
      isCurved: true,
      curveSmoothness: 0.25,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withAlpha(20),
      ),
    );
  }
}
