import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/action_message.dart';
import '../models/gesture_config_model.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../widgets/gantia_button.dart';
import '../widgets/settings_card.dart';

class LearnSection extends ConsumerStatefulWidget {
  const LearnSection({super.key});

  @override
  ConsumerState<LearnSection> createState() => _LearnSectionState();
}

class _LearnSectionState extends ConsumerState<LearnSection> {
  int _learnStep = 0;
  bool _learnInProgress = false;
  String? _learnActionKey;

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(learningServiceProvider);

    return SettingsCard(
      icon: Icons.auto_fix_high,
      title: 'Aprender Gesto',
      description: 'Crear un gesto nuevo mediante muestras',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_learnInProgress) ...[
            Text(
              'Realizá un gesto 3 veces y el asistente lo '
              'analizará para configurarlo.',
              style: TextStyle(fontSize: 12, color: context.surface600),
            ),
            const SizedBox(height: Spacing.sm),
            GantiaButton(
              label: 'Iniciar Asistente',
              icon: Icons.play_arrow,
              variant: GantiaButtonVariant.primary,
              onPressed: () => _startLearnWizard(service),
            ),
          ] else ...[
            _buildLearnStepContent(service),
            const SizedBox(height: Spacing.sm),
            if (service.isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLearnStepContent(LearningService service) {
    switch (_learnStep) {
      case 0:
        return _learnStepConnect(service);
      case 1:
        return _learnStepSample(service);
      case 2:
        return _learnStepReview(service);
      case 3:
        return _learnStepSave(service);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _learnStepConnect(LearningService service) {
    final telemetry = ref.watch(gloveStateProvider).telemetry;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _learnStepHeader('Paso 1/4', 'Conectá el guante'),
        const SizedBox(height: Spacing.sm),
        if (telemetry != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary500.withAlpha(12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle,
                    size: 18, color: AppColors.primary500),
                const SizedBox(width: 6),
                Text(
                  'Guante conectado — '
                  'Índice: ${telemetry.flexIndex}, '
                  'Medio: ${telemetry.flexMiddle}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),
          GantiaButton(
            label: 'Comenzar Aprendizaje',
            icon: Icons.fingerprint,
            variant: GantiaButtonVariant.primary,
            onPressed: () async {
              final session = await service.start();
              if (session != null) {
                setState(() {
                  _learnInProgress = true;
                  _learnStep = 1;
                });
              }
            },
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: context.surface100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.bluetooth_disabled,
                    size: 18, color: context.surface400),
                const SizedBox(width: 6),
                Text(
                  'Esperando conexión del guante...',
                  style: TextStyle(fontSize: 12, color: context.surface500),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: Spacing.sm),
        GantiaButton(
          label: 'Cancelar',
          variant: GantiaButtonVariant.danger,
          onPressed: () => _cancelLearn(service),
        ),
      ],
    );
  }

  Widget _learnStepSample(LearningService service) {
    final samples = service.session?.samplesCollected ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _learnStepHeader(
          'Paso 2/4',
          'Realizá el gesto $samples/3 veces',
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
            children: [
              for (int i = 0; i < 3; i++) ...[
                Icon(
                  i < samples
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: i < samples
                      ? AppColors.primary500
                      : context.surface400,
                ),
                if (i < 2) const SizedBox(width: 8),
              ],
              const Spacer(),
              Text(
                '$samples/3',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.surface600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),
        if (samples < 3)
          GantiaButton(
            label: samples == 0
                ? 'Capturar Muestra 1'
                : samples == 1
                    ? 'Capturar Muestra 2'
                    : 'Capturar Muestra 3',
            icon: Icons.touch_app,
            variant: GantiaButtonVariant.primary,
            onPressed: () async {
              final analysis = await service.sample();
              if (analysis != null && samples + 1 >= 3) {
                setState(() => _learnStep = 2);
              } else {
                setState(() {});
              }
            },
          ),
        if (service.error != null) ...[
          const SizedBox(height: Spacing.xs),
          Text(
            service.error!,
            style: TextStyle(fontSize: 12, color: AppColors.red500),
          ),
        ],
        const SizedBox(height: Spacing.sm),
        GantiaButton(
          label: 'Cancelar',
          variant: GantiaButtonVariant.danger,
          onPressed: () => _cancelLearn(service),
        ),
      ],
    );
  }

  Widget _learnStepReview(LearningService service) {
    final analysis = service.analysis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _learnStepHeader('Paso 3/4', 'Analizando gesto'),
        const SizedBox(height: Spacing.sm),
        if (analysis != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary500.withAlpha(10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _analysisRow(
                  'Movimiento',
                  getMovementLabel(analysis.movement),
                ),
                const SizedBox(height: 4),
                _analysisRow(
                  'Orientación',
                  getOrientationLabel(analysis.orientation),
                ),
                const SizedBox(height: 4),
                _analysisRow(
                  'Índice',
                  getFlexStateLabel(analysis.indexState),
                ),
                const SizedBox(height: 4),
                _analysisRow(
                  'Medio',
                  getFlexStateLabel(analysis.middleState),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),
          GantiaButton(
            label: 'Continuar → Elegir Acción',
            icon: Icons.arrow_forward,
            variant: GantiaButtonVariant.primary,
            onPressed: () {
              setState(() {
                _learnStep = 3;
                _learnActionKey ??= actions.first;
              });
            },
          ),
        ] else ...[
          Text(
            'No se pudo analizar el gesto. Intentá de nuevo.',
            style: TextStyle(fontSize: 12, color: AppColors.red500),
          ),
        ],
        const SizedBox(height: Spacing.sm),
        GantiaButton(
          label: 'Cancelar',
          variant: GantiaButtonVariant.danger,
          onPressed: () => _cancelLearn(service),
        ),
      ],
    );
  }

  Widget _learnStepSave(LearningService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _learnStepHeader('Paso 4/4', 'Guardar Gesto'),
        const SizedBox(height: Spacing.sm),
        Text(
          'Elegí la acción para este gesto:',
          style: TextStyle(fontSize: 12, color: context.surface500),
        ),
        const SizedBox(height: Spacing.sm),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.surface50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.surface200),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _learnActionKey,
              isExpanded: true,
              items: actions
                  .map((a) => DropdownMenuItem(
                        value: a,
                        child: Text(
                          getActionLabel(a),
                          style: TextStyle(
                            fontSize: 13,
                            color: context.surface700,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _learnActionKey = v),
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            Expanded(
              child: GantiaButton(
                label: 'Guardar Gesto',
                icon: Icons.save,
                variant: GantiaButtonVariant.primary,
                onPressed: _learnActionKey == null
                    ? null
                    : () async {
                        await service.save(_learnActionKey!);
                        _resetLearn(service);
                      },
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        GantiaButton(
          label: 'Cancelar',
          variant: GantiaButtonVariant.danger,
          onPressed: () => _cancelLearn(service),
        ),
      ],
    );
  }

  Widget _learnStepHeader(String step, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
            color: AppColors.primary500,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: context.surface700,
          ),
        ),
      ],
    );
  }

  Widget _analysisRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: context.surface500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.surface700,
          ),
        ),
      ],
    );
  }

  void _cancelLearn(LearningService service) {
    service.cancel();
    _resetLearn(service);
  }

  void _resetLearn(LearningService service) {
    setState(() {
      _learnInProgress = false;
      _learnStep = 0;
      _learnActionKey = null;
    });
  }

  void _startLearnWizard(LearningService service) {
    setState(() {
      _learnInProgress = true;
      _learnStep = 0;
    });
  }
}
