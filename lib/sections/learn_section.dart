import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/action_message.dart';
import '../models/gesture_config_model.dart';
import '../providers.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../widgets/gantia_button.dart';
import '../widgets/settings_card.dart';
import '../widgets/learn_step_connect.dart';
import '../widgets/learn_step_review.dart';
import '../widgets/learn_step_sample.dart';
import '../widgets/learn_step_save.dart';

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
    final telemetry = ref.watch(gloveStateProvider).telemetry;

    if (!_learnInProgress) {
      return _idleCard(service);
    }

    switch (_learnStep) {
      case 0:
        return _stepConnect(service, telemetry);
      case 1:
        return _stepSample(service);
      case 2:
        return _stepReview(service);
      case 3:
        return _stepSave(service);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _idleCard(LearningService service) {
    return SettingsCard(
      icon: Icons.auto_fix_high,
      title: 'Aprender Gesto',
      description: 'Crear un gesto nuevo mediante muestras',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Realizá un gesto 3 veces y el asistente lo analizará para configurarlo.',
            style: TextStyle(fontSize: 12, color: context.surface600)),
          const SizedBox(height: Spacing.sm),
          GantiaButton(
            label: 'Iniciar Asistente',
            icon: Icons.play_arrow,
            variant: GantiaButtonVariant.primary,
            onPressed: () => _startLearnWizard(service),
          ),
        ],
      ),
    );
  }

  Widget _stepConnect(LearningService service, dynamic telemetry) {
    return _card(isLoading: service.isLoading,
      child: LearnStepConnect(
        hasTelemetry: telemetry != null,
        telemetryInfo: 'Guante conectado — Índice: ${telemetry?.flexIndex}, Medio: ${telemetry?.flexMiddle}',
        canStart: telemetry != null,
        onStart: () async {
          final session = await service.start();
          if (session != null) setState(() { _learnInProgress = true; _learnStep = 1; });
        },
        onCancel: () => _cancelLearn(service),
      ),
    );
  }

  Widget _stepSample(LearningService service) {
    final samples = service.session?.samplesCollected ?? 0;
    return _card(isLoading: service.isLoading,
      child: LearnStepSample(
        samplesCollected: samples,
        error: service.error,
        onCapture: () async {
          final analysis = await service.sample();
          if (analysis != null && samples + 1 >= 3) {
            setState(() => _learnStep = 2);
          } else {
            setState(() {});
          }
        },
        onCancel: () => _cancelLearn(service),
      ),
    );
  }

  Widget _stepReview(LearningService service) {
    final analysis = service.analysis;
    return _card(
      child: LearnStepReview(
        hasAnalysis: analysis != null,
        analysisContent: Column(children: [
          AnalysisRow(label: 'Movimiento', value: getMovementLabel(analysis!.movement)),
          const SizedBox(height: 4),
          AnalysisRow(label: 'Orientación', value: getOrientationLabel(analysis.orientation)),
          const SizedBox(height: 4),
          AnalysisRow(label: 'Índice', value: getFlexStateLabel(analysis.indexState)),
          const SizedBox(height: 4),
          AnalysisRow(label: 'Medio', value: getFlexStateLabel(analysis.middleState)),
        ]),
        onContinue: () => setState(() { _learnStep = 3; _learnActionKey ??= actions.first; }),
        onCancel: () => _cancelLearn(service),
      ),
    );
  }

  Widget _stepSave(LearningService service) {
    return _card(
      child: LearnStepSave(
        selectedAction: _learnActionKey,
        actionItems: actions.map((a) => DropdownMenuItem(
          value: a,
          child: Text(getActionLabel(a), style: TextStyle(fontSize: 13, color: context.surface700)),
        )).toList(),
        onActionChanged: (v) => setState(() => _learnActionKey = v),
        onSave: () async {
          await service.save(_learnActionKey!);
          _resetLearn(service);
        },
        onCancel: () => _cancelLearn(service),
      ),
    );
  }

  Widget _card({required Widget child, bool isLoading = false}) {
    return SettingsCard(
      icon: Icons.auto_fix_high,
      title: 'Aprender Gesto',
      description: 'Crear un gesto nuevo mediante muestras',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          if (isLoading)
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }

  void _cancelLearn(LearningService service) {
    service.cancel();
    _resetLearn(service);
  }

  void _resetLearn(LearningService service) {
    setState(() { _learnInProgress = false; _learnStep = 0; _learnActionKey = null; });
  }

  void _startLearnWizard(LearningService service) {
    setState(() { _learnInProgress = true; _learnStep = 0; });
  }
}
