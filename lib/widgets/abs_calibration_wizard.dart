import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import 'gantia_button.dart';

class AbsCalibrationWizard extends ConsumerStatefulWidget {
  final int screenWidth;
  final int screenHeight;

  const AbsCalibrationWizard({
    super.key,
    this.screenWidth = 1920,
    this.screenHeight = 1080,
  });

  @override
  ConsumerState<AbsCalibrationWizard> createState() => _AbsCalibrationWizardState();
}

class _AbsCalibrationWizardState extends ConsumerState<AbsCalibrationWizard> {
  int _step = 0;
  final Map<String, Map<String, double>?> _corners = {
    'tl': null, 'tr': null, 'bl': null, 'br': null,
  };
  late int _screenWidth;
  late int _screenHeight;
  late final TextEditingController _widthCtrl;
  late final TextEditingController _heightCtrl;
  bool _saving = false;
  bool _introDone = false;

  static const _cornerSteps = [
    ('tl', 'Sup. Izquierda', 'Incliná arriba-izquierda', Icons.arrow_upward),
    ('tr', 'Sup. Derecha', 'Incliná arriba-derecha', Icons.arrow_forward),
    ('bl', 'Inf. Izquierda', 'Incliná abajo-izquierda', Icons.arrow_back),
    ('br', 'Inf. Derecha', 'Incliná abajo-derecha', Icons.arrow_downward),
  ];

  @override
  void initState() {
    super.initState();
    _screenWidth = widget.screenWidth;
    _screenHeight = widget.screenHeight;
    _widthCtrl = TextEditingController(text: _screenWidth.toString());
    _heightCtrl = TextEditingController(text: _screenHeight.toString());
  }

  @override
  void dispose() {
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    return AlertDialog(
      backgroundColor: context.surface0,
      title: Text('Calibración Puntero Absoluto',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.surface800)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_step == 0) _introStep(),
              if (_step >= 1 && _step <= 4) _captureStep(_step - 1, telemetry, livePitch, liveRoll),
              if (_step == 5) _saveStep(livePitch, liveRoll),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar', style: TextStyle(color: context.surface500)),
        ),
      ],
    );
  }

  Widget _introStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Este asistente te guiará para calibrar las 4 esquinas. '
            'Incliná tu mano hacia cada esquina y presioná el botón para registrar.',
          style: TextStyle(fontSize: 12, color: context.surface600)),
        const SizedBox(height: Spacing.md),
        SizedBox(
          width: double.infinity,
          child: GantiaButton(
            label: 'Comenzar Calibración',
            icon: Icons.play_arrow,
            variant: GantiaButtonVariant.primary,
            onPressed: () => setState(() => _step = 1),
          ),
        ),
      ],
    );
  }

  Widget _captureStep(int idx, dynamic telemetry, double livePitch, double liveRoll) {
    final step = _cornerSteps[idx];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paso ${idx + 1} de 4',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary500)),
        const SizedBox(height: Spacing.xs),
        Text(step.$2,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.surface700)),
        const SizedBox(height: 4),
        Text(step.$3,
          style: TextStyle(fontSize: 12, color: context.surface500)),
        const SizedBox(height: Spacing.sm),
        if (telemetry == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: AppColors.amber500.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              Icon(Icons.bluetooth_disabled, size: 16, color: AppColors.amber600),
              const SizedBox(width: 6),
              Text('Esperando datos del guante...',
                style: TextStyle(fontSize: 11, color: AppColors.amber700)),
            ]),
          ),
        const SizedBox(height: Spacing.sm),
        _readingsDisplay(livePitch, liveRoll),
        const SizedBox(height: Spacing.sm),
        SizedBox(
          width: double.infinity,
          child: GantiaButton(
            label: 'Capturar ${step.$2}',
            icon: Icons.check,
            variant: GantiaButtonVariant.primary,
            onPressed: telemetry == null
                ? null
                : () {
                    _corners[step.$1] = {'pitch': livePitch, 'roll': liveRoll};
                    setState(() => _step = idx + 2 > 4 ? 5 : idx + 2);
                  },
          ),
        ),
      ],
    );
  }

  Widget _readingsDisplay(double livePitch, double liveRoll) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: context.surface100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _column('Pitch', livePitch.toStringAsFixed(2)),
          _column('Roll', liveRoll.toStringAsFixed(2)),
        ],
      ),
    );
  }

  Widget _column(String label, String value) {
    return Column(children: [
      Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.surface500)),
      const SizedBox(height: 2),
      Text(value,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
          color: AppColors.primary500, fontFeatures: [FontFeature.tabularFigures()])),
    ]);
  }

  Widget _saveStep(double livePitch, double liveRoll) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Calibración Completa',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.green600)),
        const SizedBox(height: Spacing.sm),
        ..._cornerSteps.map((s) {
          final data = _corners[s.$1];
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: context.surface100, borderRadius: BorderRadius.circular(6)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(s.$2,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.surface700)),
                if (data != null)
                  Text('P: ${data['pitch']!.toStringAsFixed(1)} R: ${data['roll']!.toStringAsFixed(1)}',
                    style: TextStyle(fontSize: 11, color: context.surface500)),
              ],
            ),
          );
        }),
        const SizedBox(height: Spacing.sm),
        Row(children: [
          Expanded(child: _sizeField('Ancho (px)', _widthCtrl, (v) => _screenWidth = v)),
          const SizedBox(width: Spacing.sm),
          Expanded(child: _sizeField('Alto (px)', _heightCtrl, (v) => _screenHeight = v)),
        ]),
        const SizedBox(height: Spacing.sm),
        SizedBox(
          width: double.infinity,
          child: GantiaButton(
            label: _saving ? 'Guardando...' : 'Guardar Calibración',
            icon: Icons.save,
            variant: GantiaButtonVariant.primary,
            onPressed: _saving ? null : _save,
          ),
        ),
      ],
    );
  }

  Widget _sizeField(String label, TextEditingController ctrl, void Function(int) onChange) {
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
      controller: ctrl,
      style: TextStyle(fontSize: 13, color: context.surface700),
      onChanged: (v) {
        final parsed = int.tryParse(v);
        if (parsed != null && parsed > 0) onChange(parsed);
      },
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final api = ref.read(apiServiceProvider);
      final corners = <String, dynamic>{};
      for (final e in _corners.entries) {
        corners[e.key] = e.value ?? {'pitch': 0, 'roll': 0};
      }
      await api.put('/config/absolute-pointer/calibration', body: {
        'corners': corners,
        'screen_width': _screenWidth,
        'screen_height': _screenHeight,
      });
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calibración guardada')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: AppColors.red500));
      }
    }
  }
}
