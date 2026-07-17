import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';
import '../theme/spacing.dart';

enum SensorType { accelerometer, gyroscope, flexion }

extension SensorTypeX on SensorType {
  List<String> get legendLabels {
    return switch (this) {
      SensorType.accelerometer => ['X', 'Y', 'Z'],
      SensorType.gyroscope => ['X', 'Y', 'Z'],
      SensorType.flexion => ['Índice', 'Medio'],
    };
  }

  List<Color> get colors {
    return switch (this) {
      SensorType.accelerometer => [AppColors.cyan500, AppColors.primary500, AppColors.warning500],
      SensorType.gyroscope => [AppColors.purple500, AppColors.primary500, AppColors.warning500],
      SensorType.flexion => [AppColors.primary500, AppColors.warning500],
    };
  }

  double get minY {
    return switch (this) {
      SensorType.accelerometer => -2.5,
      SensorType.gyroscope => -250,
      SensorType.flexion => 0,
    };
  }

  double get maxY {
    return switch (this) {
      SensorType.accelerometer => 2.5,
      SensorType.gyroscope => 250,
      SensorType.flexion => 100,
    };
  }

  String get title {
    return switch (this) {
      SensorType.accelerometer => 'ACELERÓMETRO',
      SensorType.gyroscope => 'GIROSCOPIO',
      SensorType.flexion => 'FLEXIÓN',
    };
  }
}

class SensorChart extends StatelessWidget {
  final SensorType sensorType;
  final List<List<double>> lines;
  final bool showTimeAxis;
  final bool showTitle;
  final double height;
  final bool animated;

  const SensorChart({
    super.key,
    required this.sensorType,
    required this.lines,
    this.showTimeAxis = false,
    this.showTitle = false,
    this.height = 140,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    final dataPoints = lines.isNotEmpty ? lines.first.length : 0;

    final theme = context.findAncestorWidgetOfExactType<Theme>();
    final isDark = theme?.data.brightness == Brightness.dark;
    final gridColor = isDark ? const Color(0xFF3a3732) : const Color(0xFFd4cec4);
    final axisTextColor = isDark ? const Color(0xFF5c5850) : const Color(0xFF9c9588);
    const textColor = Color(0xFF7d776b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.xs),
            child: Text(
              sensorType.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.primary600,
              ),
            ),
          ),
        SizedBox(
          height: height,
          child: dataPoints < 2
              ? Center(
                  child: Text(
                    showTimeAxis
                        ? 'Se necesitan al menos 2 lecturas'
                        : 'Esperando datos...',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor,
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
                        color: gridColor,
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
                              color: axisTextColor,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: showTimeAxis
                          ? AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 24,
                                interval: _intervalForLength(dataPoints),
                                getTitlesWidget: (v, _) => Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    v.toStringAsFixed(0),
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: axisTextColor,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const AxisTitles(
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
                    maxX: (dataPoints - 1).toDouble(),
                    minY: sensorType.minY,
                    maxY: sensorType.maxY,
                    lineBarsData: _buildLines(),
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                          return LineTooltipItem(
                            s.y.toStringAsFixed(1),
                            TextStyle(
                              color: sensorType.colors[s.barIndex % sensorType.colors.length],
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  duration: animated
                      ? const Duration(milliseconds: 150)
                      : Duration.zero,
                ),
        ),
        const SizedBox(height: Spacing.xxs),
        Row(
          children: sensorType.legendLabels.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: sensorType.colors[e.key],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 10,
                      color: textColor,
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

  double _intervalForLength(int length) {
    if (length <= 5) return 1;
    return (length / 5).ceilToDouble();
  }

  List<LineChartBarData> _buildLines() {
    return [
      for (var i = 0; i < lines.length; i++) _buildLine(lines[i], sensorType.colors[i]),
    ];
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
      curveSmoothness: 0.2,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withAlpha(20),
      ),
    );
  }
}
