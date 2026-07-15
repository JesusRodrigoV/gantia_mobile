import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../widgets/gantia_button.dart';
import '../widgets/settings_card.dart';

class AbsolutePointerSection extends ConsumerStatefulWidget {
  const AbsolutePointerSection({super.key});

  @override
  ConsumerState<AbsolutePointerSection> createState() =>
      _AbsolutePointerSectionState();
}

class _AbsolutePointerSectionState
    extends ConsumerState<AbsolutePointerSection> {
  bool? _absCalibrationExists;
  bool _absCalibSaving = false;
  int _absCalibStep = 0;
  final Map<String, Map<String, double>?> _absCalibCorners = {
    'tl': null,
    'tr': null,
    'bl': null,
    'br': null,
  };
  int _absScreenWidth = 1920;
  int _absScreenHeight = 1080;
  final _absWidthCtrl = TextEditingController(text: '1920');
  final _absHeightCtrl = TextEditingController(text: '1080');

  @override
  void dispose() {
    _absWidthCtrl.dispose();
    _absHeightCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAbsCalibration();
    });
  }

  Future<void> _checkAbsCalibration() async {
    try {
      final api = ref.read(apiServiceProvider);
      await api.get('/absolute-pointer/calibration');
      if (mounted) setState(() => _absCalibrationExists = true);
    } catch (_) {
      if (mounted) setState(() => _absCalibrationExists = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final glove = ref.watch(gloveStateProvider);
    final absEnabled = glove.absolutePointerEnabled;

    return SettingsCard(
      icon: Icons.my_location,
      title: 'Puntero Absoluto',
      description: 'Mapea inclinación de mano a posición en pantalla',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _absCalibrationExists == null
                    ? 'Verificando...'
                    : _absCalibrationExists!
                        ? 'Calibrado'
                        : 'No calibrado',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _absCalibrationExists == null
                      ? context.surface500
                      : _absCalibrationExists!
                          ? AppColors.green500
                          : AppColors.amber600,
                ),
              ),
              Switch(
                value: absEnabled,
                onChanged: _absCalibrationExists == true
                    ? (v) {
                        glove.sendToggleAbsolutePointer(v);
                      }
                    : null,
                activeThumbColor: AppColors.primary500,
              ),
            ],
          ),

          if (_absCalibrationExists == false) ...[
            const SizedBox(height: Spacing.xs),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: AppColors.amber500.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: AppColors.amber600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Se requiere calibración antes de usar puntero absoluto',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.amber700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: Spacing.sm),

          Text(
            'En modo PRESENTATION, la inclinación de la mano se mapea a '
            'posición absoluta del cursor. Sin deriva, sin yaw.',
            style: TextStyle(fontSize: 11, color: context.surface500),
          ),

          const SizedBox(height: Spacing.sm),

          SizedBox(
            width: double.infinity,
            child: GantiaButton(
              label: _absCalibrationExists == true
                  ? 'Recalibrar'
                  : 'Iniciar Calibración',
              icon: Icons.sensors,
              variant: GantiaButtonVariant.primary,
              onPressed: _showAbsCalibrationWizard,
            ),
          ),
        ],
      ),
    );
  }

  void _showAbsCalibrationWizard() {
    setState(() {
      _absCalibStep = 0;
      _absCalibCorners.updateAll((k, v) => null);
      _absWidthCtrl.text = _absScreenWidth.toString();
      _absHeightCtrl.text = _absScreenHeight.toString();
    });

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final telemetry = ref.read(gloveStateProvider).telemetry;

            double livePitch = 0;
            double liveRoll = 0;
            if (telemetry != null) {
              final g = (telemetry.accelX * telemetry.accelX +
                      telemetry.accelY * telemetry.accelY +
                      telemetry.accelZ * telemetry.accelZ)
                  .clamp(0.01, double.infinity);
              final gNorm = g > 0.1 ? g : 1.0;
              livePitch = -(telemetry.accelX / gNorm);
              liveRoll = telemetry.accelY / gNorm;
            }

            const cornerSteps = [
              ('tl', 'Sup. Izquierda', 'Incliná arriba-izquierda', Icons.arrow_upward),
              ('tr', 'Sup. Derecha', 'Incliná arriba-derecha', Icons.arrow_forward),
              ('bl', 'Inf. Izquierda', 'Incliná abajo-izquierda', Icons.arrow_back),
              ('br', 'Inf. Derecha', 'Incliná abajo-derecha', Icons.arrow_downward),
            ];

            return AlertDialog(
              backgroundColor: context.surface0,
              title: Text(
                'Calibración Puntero Absoluto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.surface800,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_absCalibStep == 0) ...[
                        Text(
                          'Este asistente te guiará para calibrar las 4 esquinas. '
                          'Incliná tu mano hacia cada esquina y presioná el botón para registrar.',
                          style: TextStyle(fontSize: 12, color: context.surface600),
                        ),
                        const SizedBox(height: Spacing.md),
                        SizedBox(
                          width: double.infinity,
                          child: GantiaButton(
                            label: 'Comenzar Calibración',
                            icon: Icons.play_arrow,
                            variant: GantiaButtonVariant.primary,
                            onPressed: () => setDialogState(() => _absCalibStep = 1),
                          ),
                        ),
                      ],

                      if (_absCalibStep >= 1 && _absCalibStep <= 4) ...[
                        Text(
                          'Paso $_absCalibStep de 4',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary500,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          cornerSteps[_absCalibStep - 1].$2,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: context.surface700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cornerSteps[_absCalibStep - 1].$3,
                          style: TextStyle(fontSize: 12, color: context.surface500),
                        ),
                        const SizedBox(height: Spacing.sm),

                        if (telemetry == null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(Spacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.amber500.withAlpha(15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.bluetooth_disabled,
                                    size: 16, color: AppColors.amber600),
                                const SizedBox(width: 6),
                                Text(
                                  'Esperando datos del guante...',
                                  style: TextStyle(
                                      fontSize: 11, color: AppColors.amber700),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: Spacing.sm),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(Spacing.sm),
                          decoration: BoxDecoration(
                            color: context.surface100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _absReadingColumn(
                                  'Pitch', livePitch.toStringAsFixed(2)),
                              _absReadingColumn(
                                  'Roll', liveRoll.toStringAsFixed(2)),
                            ],
                          ),
                        ),

                        const SizedBox(height: Spacing.sm),

                        SizedBox(
                          width: double.infinity,
                          child: GantiaButton(
                            label:
                                'Capturar ${cornerSteps[_absCalibStep - 1].$2}',
                            icon: Icons.check,
                            variant: GantiaButtonVariant.primary,
                            onPressed: telemetry == null
                                ? null
                                : () {
                                    final key = cornerSteps[_absCalibStep - 1].$1;
                                    _absCalibCorners[key] = {
                                      'pitch': livePitch,
                                      'roll': liveRoll,
                                    };
                                    if (_absCalibStep >= 4) {
                                      setDialogState(() => _absCalibStep = 5);
                                    } else {
                                      setDialogState(
                                          () => _absCalibStep++);
                                    }
                                  },
                          ),
                        ),
                      ],

                      if (_absCalibStep == 5) ...[
                        const Text(
                          'Calibración Completa',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green600,
                          ),
                        ),
                        const SizedBox(height: Spacing.sm),
                        ...cornerSteps.map((step) {
                          final key = step.$1;
                          final data = _absCalibCorners[key];
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: context.surface100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  step.$2,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: context.surface700,
                                  ),
                                ),
                                if (data != null)
                                  Text(
                                    'P: ${data['pitch']!.toStringAsFixed(1)} '
                                    'R: ${data['roll']!.toStringAsFixed(1)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: context.surface500,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: Spacing.sm),

                        Row(
                          children: [
                            Expanded(
                              child: _absSizeField(
                                'Ancho (px)',
                                _absWidthCtrl,
                                (v) => _absScreenWidth = v,
                              ),
                            ),
                            const SizedBox(width: Spacing.sm),
                            Expanded(
                              child: _absSizeField(
                                'Alto (px)',
                                _absHeightCtrl,
                                (v) => _absScreenHeight = v,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: Spacing.sm),

                        SizedBox(
                          width: double.infinity,
                          child: GantiaButton(
                            label: _absCalibSaving
                                ? 'Guardando...'
                                : 'Guardar Calibración',
                            icon: Icons.save,
                            variant: GantiaButtonVariant.primary,
                            onPressed: _absCalibSaving
                                ? null
                                : () => _saveAbsCalibration(ctx),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: context.surface500),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _absReadingColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: context.surface500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.primary500,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _absSizeField(
    String label,
    TextEditingController controller,
    void Function(int) onChanged,
  ) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: context.surface500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.surface200),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      controller: controller,
      style: TextStyle(fontSize: 13, color: context.surface700),
      onChanged: (v) {
        final parsed = int.tryParse(v);
        if (parsed != null && parsed > 0) onChanged(parsed);
      },
    );
  }

  Future<void> _saveAbsCalibration(BuildContext dialogContext) async {
    setState(() => _absCalibSaving = true);

    try {
      final api = ref.read(apiServiceProvider);
      final navigator = Navigator.of(dialogContext);
      final messenger = ScaffoldMessenger.of(context);
      final corners = <String, dynamic>{};
      for (final entry in _absCalibCorners.entries) {
        if (entry.value != null) {
          corners[entry.key] = entry.value;
        } else {
          corners[entry.key] = {'pitch': 0, 'roll': 0};
        }
      }

      await api.put('/absolute-pointer/calibration', body: {
        'corners': corners,
        'screen_width': _absScreenWidth,
        'screen_height': _absScreenHeight,
      });

      if (mounted) {
        setState(() {
          _absCalibrationExists = true;
          _absCalibSaving = false;
        });
        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(content: Text('Calibración guardada')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _absCalibSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppColors.red500,
          ),
        );
      }
    }
  }
}
