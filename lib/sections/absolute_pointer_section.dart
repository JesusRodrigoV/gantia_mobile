import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../widgets/abs_calibration_wizard.dart';
import '../widgets/gantia_button.dart';
import '../widgets/settings_card.dart';

class AbsolutePointerSection extends ConsumerStatefulWidget {
  const AbsolutePointerSection({super.key});

  @override
  ConsumerState<AbsolutePointerSection> createState() => _AbsolutePointerSectionState();
}

class _AbsolutePointerSectionState extends ConsumerState<AbsolutePointerSection> {
  bool? _calibrationExists;
  final int _screenWidth = 1920;
  final int _screenHeight = 1080;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkCalibration());
  }

  Future<void> _checkCalibration() async {
    final exists = await ref.read(calibrationServiceProvider).hasCalibration();
    if (mounted) setState(() => _calibrationExists = exists);
  }

  @override
  Widget build(BuildContext context) {
    final glove = ref.watch(gloveStateProvider);  
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
                _calibrationExists == null ? 'Verificando...'
                    : _calibrationExists! ? 'Calibrado' : 'No calibrado',
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: _calibrationExists == null ? context.surface500
                      : _calibrationExists! ? AppColors.green500 : AppColors.amber600,
                ),
              ),
              Switch(
                value: glove.absolutePointerEnabled,
                onChanged: _calibrationExists == true
                    ? (v) => glove.sendToggleAbsolutePointer(v) : null,
                activeThumbColor: AppColors.primary500,
              ),
            ],
          ),
          if (_calibrationExists == false) ...[
            const SizedBox(height: Spacing.xs),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: AppColors.amber500.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.amber600),
                const SizedBox(width: 6),
                Expanded(child: Text('Se requiere calibración antes de usar puntero absoluto',
                  style: TextStyle(fontSize: 11, color: AppColors.amber700))),
              ]),
            ),
          ],
          const SizedBox(height: Spacing.sm),
          Text('En modo PRESENTATION, la inclinación de la mano se mapea a '
              'posición absoluta del cursor. Sin deriva, sin yaw.',
            style: TextStyle(fontSize: 11, color: context.surface500)),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            width: double.infinity,
            child: GantiaButton(
              label: _calibrationExists == true ? 'Recalibrar' : 'Iniciar Calibración',
              icon: Icons.sensors,
              variant: GantiaButtonVariant.primary,
              onPressed: () => showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => AbsCalibrationWizard(
                  screenWidth: _screenWidth,
                  screenHeight: _screenHeight,
                ),
              ).then((_) => _checkCalibration()),
            ),
          ),
        ],
      ),
    );
  }
}
