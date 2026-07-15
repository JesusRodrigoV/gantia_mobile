import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/action_message.dart';
import '../models/gesture_config_model.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../widgets/settings_card.dart';

class TestModeSection extends ConsumerStatefulWidget {
  const TestModeSection({super.key});

  @override
  ConsumerState<TestModeSection> createState() => _TestModeSectionState();
}

class _TestModeSectionState extends ConsumerState<TestModeSection> {
  bool _testMode = false;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      icon: Icons.science,
      title: 'Modo Prueba',
      description: 'Ver telemetría en vivo del guante',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _testMode ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _testMode ? AppColors.primary500 : context.surface500,
                ),
              ),
              Switch(
                value: _testMode,
                onChanged: (v) => setState(() => _testMode = v),
                activeThumbColor: AppColors.primary500,
              ),
            ],
          ),
          if (_testMode) ...[
            const SizedBox(height: Spacing.sm),
            _buildTelemetryDisplay(),
            _buildRecentActionsDisplay(),
          ],
        ],
      ),
    );
  }

  Widget _buildTelemetryDisplay() {
    final telemetry = ref.watch(gloveStateProvider).telemetry;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: context.surface100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Telemetría',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.surface500,
            ),
          ),
          const SizedBox(height: 6),
          if (telemetry != null) ...[
            _telemetryRow('Índice', '${telemetry.flexIndex}',
                getFlexStateLabel(telemetry.indexState)),
            _telemetryRow('Medio', '${telemetry.flexMiddle}',
                getFlexStateLabel(telemetry.middleState)),
            _telemetryRow(
              'Acel',
              '${telemetry.accelX.toStringAsFixed(1)}, '
                  '${telemetry.accelY.toStringAsFixed(1)}, '
                  '${telemetry.accelZ.toStringAsFixed(1)}',
              null,
            ),
            _telemetryRow(
              'Giro',
              '${telemetry.gyroX.toStringAsFixed(1)}, '
                  '${telemetry.gyroY.toStringAsFixed(1)}, '
                  '${telemetry.gyroZ.toStringAsFixed(1)}',
              null,
            ),
          ] else
            Text(
              'Esperando datos del guante...',
              style: TextStyle(fontSize: 12, color: context.surface500),
            ),
        ],
      ),
    );
  }

  Widget _telemetryRow(String label, String value, String? tag) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: context.surface500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.surface700,
              ),
            ),
          ),
          if (tag != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.primary500.withAlpha(20),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentActionsDisplay() {
    final recent = ref.watch(actionLogProvider).recentActions;

    if (recent.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones recientes',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.surface500,
            ),
          ),
          const SizedBox(height: 4),
          ...recent.take(5).map((evt) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    Icon(Icons.touch_app,
                        size: 14, color: AppColors.primary400),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        getActionLabel(evt.action),
                        style: TextStyle(
                          fontSize: 11,
                          color: context.surface600,
                        ),
                      ),
                    ),
                    if (evt.actionValue != null)
                      Text(
                        '${evt.actionValue}',
                        style: TextStyle(fontSize: 10, color: context.surface400),
                      ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
