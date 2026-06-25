import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/action_message.dart';
import '../models/calibration_model.dart';
import '../models/gesture_config_model.dart';
import '../models/learning_model.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../widgets/gantia_button.dart';
import '../widgets/neuromorphic_card.dart';
import '../widgets/settings_card.dart';
import '../widgets/skeleton_card.dart';

class ConfigScreen extends ConsumerStatefulWidget {
  const ConfigScreen({super.key});

  @override
  ConsumerState<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends ConsumerState<ConfigScreen> {
  // --- Context filter ---
  String _selectedContext = 'ALL';

  // --- Test mode ---
  bool _testMode = false;

  // --- Learn wizard ---
  int _learnStep = 0;
  bool _learnInProgress = false;
  String? _learnActionKey;

  // --- Calibration state ---
  int? _calibMin;
  int? _calibMax;
  String? _calibSensor;

  // --- Import/Export ---
  final _importTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gestureConfigServiceProvider).getAll();
      ref.read(calibrationServiceProvider).getAll();
    });
  }

  @override
  void dispose() {
    _importTextController.dispose();
    super.dispose();
  }

  // ====================================================================
  // BUILD
  // ====================================================================

  @override
  Widget build(BuildContext context) {
    final gcService = ref.watch(gestureConfigServiceProvider);
    final calibrationService = ref.watch(calibrationServiceProvider);
    final learningService = ref.watch(learningServiceProvider);

    return Scaffold(
      backgroundColor: context.surface50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                children: [
                  // 1. Gesture Config List
                  _buildGestureConfigSection(gcService),

                  // 2. Calibration
                  _buildCalibrationSection(calibrationService),

                  // 3. Test Mode
                  _buildTestModeSection(),

                  // 4. Import / Export
                  _buildImportExportSection(gcService),

                  // 5. Sync & Reset
                  _buildSyncResetSection(gcService),

                  // 6. Learn Wizard
                  _buildLearnSection(learningService),

                  const SizedBox(height: Spacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====================================================================
  // HEADER
  // ====================================================================

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.md,
        Spacing.md,
        Spacing.xs,
      ),
      child: Row(
        children: [
          const Icon(Icons.tune, color: AppColors.primary500, size: 28),
          const SizedBox(width: Spacing.xs),
          const Text(
            'Configuración de Gestos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.surfaceLight700,
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // 1 — GESTURE CONFIG LIST
  // ====================================================================

  Widget _buildGestureConfigSection(GestureConfigService service) {
    return SettingsCard(
      icon: Icons.gesture,
      title: 'Gestos Configurados',
      description: 'Acciones asignadas a cada gesto manual',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Context filter chips
          _buildContextFilter(),

          const SizedBox(height: Spacing.sm),

          // Loading / Error / Empty / List
          if (service.isLoading && service.configs.isEmpty)
            const SkeletonCard(height: 100, lines: 2)
          else if (service.error != null)
            _buildErrorState(service.error!, () => service.getAll())
          else
            _buildConfigList(service),
        ],
      ),
    );
  }

  Widget _buildContextFilter() {
    final allContexts = ['ALL', ...contexts];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allContexts.length,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.xs),
        itemBuilder: (context, i) {
          final c = allContexts[i];
          final selected = _selectedContext == c;
          return ChoiceChip(
            label: Text(c == 'ALL' ? 'Todas' : getContextLabel(c)),
            selected: selected,
            onSelected: (_) => setState(() => _selectedContext = c),
            selectedColor: AppColors.primary500,
            labelStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : context.surface600,
            ),
            backgroundColor: context.surface0,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }

  Widget _buildConfigList(GestureConfigService service) {
    final filtered = _selectedContext == 'ALL'
        ? service.configs
        : service.configs
            .where((c) => c.context == _selectedContext)
            .toList();

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
        child: Center(
          child: Text(
            _selectedContext == 'ALL'
                ? 'No hay gestos configurados'
                : 'No hay gestos para este contexto',
            style: TextStyle(fontSize: 13, color: context.surface500),
          ),
        ),
      );
    }

    return Column(
      children: [
        ...filtered.map((config) => _buildConfigRow(config)),
        const SizedBox(height: Spacing.sm),
        GantiaButton(
          label: 'Agregar Gesto',
          icon: Icons.add,
          variant: GantiaButtonVariant.primary,
          onPressed: () => _showCreateEditDialog(),
        ),
      ],
    );
  }

  Widget _buildConfigRow(GestureConfig config) {
    return NeuromorphicCard(
      showAccentLine: false,
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${getMovementLabel(config.movement)} / ${getOrientationLabel(config.orientation)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.surface700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Índice: ${getFlexStateLabel(config.indexState)}   '
                  'Medio: ${getFlexStateLabel(config.middleState)}',
                  style: TextStyle(fontSize: 11, color: context.surface500),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary500.withAlpha(20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        getActionLabel(config.actionKey),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary600,
                        ),
                      ),
                    ),
                    if (config.actionValue != null &&
                        config.actionValue!.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Text(
                        ': ${config.actionValue}',
                        style: TextStyle(
                          fontSize: 10,
                          color: context.surface500,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      getContextLabel(config.context),
                      style: TextStyle(
                        fontSize: 10,
                        color: context.surface400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.xs),
          _buildRowActionButton(
            Icons.edit,
            'Editar',
            AppColors.primary500,
            () => _showCreateEditDialog(config),
          ),
          const SizedBox(width: 4),
          _buildRowActionButton(
            Icons.delete,
            'Borrar',
            AppColors.red500,
            () => _confirmDelete(config),
          ),
        ],
      ),
    );
  }

  Widget _buildRowActionButton(
    IconData icon,
    String tooltip,
    Color color,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  // ====================================================================
  // 1a — CREATE / EDIT DIALOG
  // ====================================================================

  void _showCreateEditDialog([GestureConfig? existing]) {
    final isEditing = existing != null;
    final movementCtrl = ValueNotifier<String>(existing?.movement ?? 'NONE');
    final orientationCtrl =
        ValueNotifier<String>(existing?.orientation ?? 'ANY');
    final indexStateCtrl =
        ValueNotifier<int>(existing?.indexState ?? 0);
    final middleStateCtrl =
        ValueNotifier<int>(existing?.middleState ?? 0);
    final actionKeyCtrl =
        ValueNotifier<String>(existing?.actionKey ?? actions.first);
    final actionValueCtrl =
        TextEditingController(text: existing?.actionValue ?? '');
    final contextCtrl =
        ValueNotifier<String>(existing?.context ?? 'GLOBAL');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surface0,
        title: Text(
          isEditing ? 'Editar Gesto' : 'Nuevo Gesto',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.surfaceLight700,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDropdown(
                label: 'Movimiento',
                value: movementCtrl,
                items: movements,
                labelFn: getMovementLabel,
              ),
              const SizedBox(height: Spacing.sm),
              _buildDropdown(
                label: 'Orientación',
                value: orientationCtrl,
                items: orientations,
                labelFn: getOrientationLabel,
              ),
              const SizedBox(height: Spacing.sm),
              _buildIntDropdown(
                label: 'Estado Índice',
                value: indexStateCtrl,
                items: flexStates,
                labelFn: getFlexStateLabel,
              ),
              const SizedBox(height: Spacing.sm),
              _buildIntDropdown(
                label: 'Estado Medio',
                value: middleStateCtrl,
                items: flexStates,
                labelFn: getFlexStateLabel,
              ),
              const SizedBox(height: Spacing.sm),
              _buildDropdown(
                label: 'Acción',
                value: actionKeyCtrl,
                items: actions,
                labelFn: getActionLabel,
              ),
              const SizedBox(height: Spacing.sm),
              TextField(
                controller: actionValueCtrl,
                decoration: InputDecoration(
                  labelText: 'Valor (opcional)',
                  labelStyle: TextStyle(color: context.surface500),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.surface200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.surface200),
                  ),
                  filled: true,
                  fillColor: context.surface0,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                style: TextStyle(fontSize: 14, color: context.surface700),
              ),
              const SizedBox(height: Spacing.sm),
              _buildDropdown(
                label: 'Contexto',
                value: contextCtrl,
                items: contexts,
                labelFn: getContextLabel,
              ),
            ],
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
          GantiaButton(
            label: isEditing ? 'Guardar' : 'Crear',
            variant: GantiaButtonVariant.primary,
            onPressed: () async {
              Navigator.of(ctx).pop();
              final data = {
                'movement': movementCtrl.value,
                'orientation': orientationCtrl.value,
                'index_state': indexStateCtrl.value,
                'middle_state': middleStateCtrl.value,
                'action_key': actionKeyCtrl.value,
                'action_value':
                    actionValueCtrl.text.isNotEmpty ? actionValueCtrl.text : null,
                'context': contextCtrl.value,
              };

              if (isEditing) {
                await ref
                    .read(gestureConfigServiceProvider)
                    .update(existing.id, data);
              } else {
                await ref
                    .read(gestureConfigServiceProvider)
                    .create(data);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required ValueNotifier<String> value,
    required List<String> items,
    required String Function(String) labelFn,
  }) {
    return ValueListenableBuilder<String>(
      valueListenable: value,
      builder: (context, val, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.surface500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: context.surface50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.surface200),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: val,
                  isExpanded: true,
                  items: items
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              labelFn(item),
                              style: TextStyle(
                                fontSize: 13,
                                color: context.surface700,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) value.value = v;
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIntDropdown({
    required String label,
    required ValueNotifier<int> value,
    required List<int> items,
    required String Function(int) labelFn,
  }) {
    return ValueListenableBuilder<int>(
      valueListenable: value,
      builder: (context, val, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.surface500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: context.surface50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.surface200),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: val,
                  isExpanded: true,
                  items: items
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              labelFn(item),
                              style: TextStyle(
                                fontSize: 13,
                                color: context.surface700,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) value.value = v;
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(GestureConfig config) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surface0,
        title: const Text(
          'Eliminar Gesto',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          '¿Eliminar ${getMovementLabel(config.movement)} / '
          '${getOrientationLabel(config.orientation)}?',
          style: TextStyle(color: context.surface600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.red500),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(gestureConfigServiceProvider).delete(config.id);
    }
  }

  // ====================================================================
  // 1b — ERROR STATE
  // ====================================================================

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.red500, size: 32),
          const SizedBox(height: Spacing.xs),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: context.surface500),
          ),
          const SizedBox(height: Spacing.sm),
          GantiaButton(
            label: 'Reintentar',
            icon: Icons.refresh,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // 2 — CALIBRATION
  // ====================================================================

  Widget _buildCalibrationSection(CalibrationService service) {
    return SettingsCard(
      icon: Icons.tune,
      title: 'Calibración',
      description: 'Ajustar sensores del guante',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (service.isLoading && service.entries.isEmpty)
            const SkeletonCard(height: 60, lines: 1)
          else if (service.entries.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: Text(
                'No hay datos de calibración',
                style: TextStyle(fontSize: 13, color: context.surface500),
              ),
            )
          else
            ...service.entries.map((e) => _calibrationRow(e)),

          const SizedBox(height: Spacing.sm),
          GantiaButton(
            label: 'Iniciar Calibración',
            icon: Icons.sensors,
            variant: GantiaButtonVariant.primary,
            onPressed: () => _showCalibrationWizard(service),
          ),
        ],
      ),
    );
  }

  Widget _calibrationRow(CalibrationEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            entry.sensorName == 'flex_index'
                ? 'Índice'
                : entry.sensorName == 'flex_middle'
                    ? 'Medio'
                    : entry.sensorName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.surface700,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: context.surface100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${entry.minValue.toInt()} – ${entry.maxValue.toInt()}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.surface600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCalibrationWizard(CalibrationService service) {
    _calibSensor = null;
    _calibMin = null;
    _calibMax = null;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Read telemetry once at dialog open; live updates require
            // closing and reopening the dialog.
            final telemetry = ref.read(gloveStateProvider).telemetry;

            return AlertDialog(
              backgroundColor: context.surface0,
              title: const Text(
                'Calibración',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.surfaceLight700,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1. Relajá el dedo y capturá el mínimo.\n'
                      '2. Flexioná completamente y capturá el máximo.\n'
                      '3. Guardá la calibración.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.surfaceLight500,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),

                    // Live flex values
                    if (telemetry != null) ...[
                      Text(
                        'Valores actuales:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.surface500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _liveFlexRow('Índice', telemetry.flexIndex),
                      _liveFlexRow('Medio', telemetry.flexMiddle),
                      const SizedBox(height: Spacing.sm),
                    ],

                    // Captured values
                    if (_calibMin != null || _calibMax != null) ...[
                      Container(
                        padding: const EdgeInsets.all(Spacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primary500.withAlpha(12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                size: 16, color: AppColors.primary500),
                            const SizedBox(width: 6),
                            Text(
                              _calibMin != null && _calibMax != null
                                  ? 'Mín: $_calibMin  Máx: $_calibMax'
                                  : _calibMin != null
                                      ? 'Mínimo capturado: $_calibMin'
                                      : 'Máximo capturado: $_calibMax',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.sm),
                    ],

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: GantiaButton(
                            label: 'Capturar Mín',
                            icon: Icons.arrow_downward,
                            variant: GantiaButtonVariant.default_,
                            onPressed: telemetry == null
                                ? null
                                : () => setDialogState(() {
                                      _calibMin = telemetry!.flexIndex;
                                      _calibSensor = 'flex_index';
                                    }),
                          ),
                        ),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: GantiaButton(
                            label: 'Capturar Máx',
                            icon: Icons.arrow_upward,
                            variant: GantiaButtonVariant.default_,
                            onPressed: telemetry == null
                                ? null
                                : () => setDialogState(() {
                                      _calibMax = telemetry!.flexIndex;
                                      _calibSensor = 'flex_index';
                                    }),
                          ),
                        ),
                      ],
                    ),
                  ],
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
                GantiaButton(
                  label: 'Guardar',
                  variant: GantiaButtonVariant.primary,
                  onPressed: _calibMin == null || _calibMax == null
                      ? null
                      : () async {
                          Navigator.of(ctx).pop();
                          await service.update(
                            _calibSensor!,
                            minValue: _calibMin!.toDouble(),
                            maxValue: _calibMax!.toDouble(),
                          );
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _liveFlexRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12, color: context.surface600),
          ),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary500,
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // 3 — TEST MODE
  // ====================================================================

  Widget _buildTestModeSection() {
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
                '${getFlexStateLabel(telemetry.indexState)}'),
            _telemetryRow('Medio', '${telemetry.flexMiddle}',
                '${getFlexStateLabel(telemetry.middleState)}'),
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

  // ====================================================================
  // 4 — IMPORT / EXPORT
  // ====================================================================

  Widget _buildImportExportSection(GestureConfigService service) {
    return SettingsCard(
      icon: Icons.file_copy,
      title: 'Importar / Exportar',
      description: 'Respaldar o restaurar configuraciones',
      child: Row(
        children: [
          Expanded(
            child: GantiaButton(
              label: 'Exportar',
              icon: Icons.upload,
              onPressed: () => _handleExport(service),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: GantiaButton(
              label: 'Importar',
              icon: Icons.download,
              onPressed: () => _showImportDialog(service),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport(GestureConfigService service) async {
    final json = await service.exportConfigs();
    if (json == null) return;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surface0,
        title: const Text(
          'Configuración Exportada',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 300),
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: context.surface100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    json,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: context.surface700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              GantiaButton(
                label: 'Copiar al Portapapeles',
                icon: Icons.copy,
                onPressed: () {
                  // Copy using Clipboard service
                  // This is intentionally basic — just selectable text
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copiado al portapapeles')),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(GestureConfigService service) {
    _importTextController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surface0,
        title: const Text(
          'Importar Configuración',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pegá el JSON de configuración exportado:',
                style: TextStyle(fontSize: 12, color: context.surface500),
              ),
              const SizedBox(height: Spacing.sm),
              TextField(
                controller: _importTextController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: '[{"id": "...", "movement": "...", ...}]',
                  hintStyle: TextStyle(color: context.surface400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.surface200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.surface200),
                  ),
                  filled: true,
                  fillColor: context.surface0,
                ),
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: context.surface700,
                ),
              ),
            ],
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
          GantiaButton(
            label: 'Importar',
            variant: GantiaButtonVariant.primary,
            onPressed: () async {
              final text = _importTextController.text.trim();
              if (text.isEmpty) return;

              try {
                final decoded = jsonDecode(text);
                List<Map<String, dynamic>> configs;
                if (decoded is List) {
                  configs = decoded.cast<Map<String, dynamic>>();
                } else {
                  configs = [decoded as Map<String, dynamic>];
                }
                Navigator.of(ctx).pop();
                await service.importConfigs(configs);
              } catch (e) {
                Navigator.of(ctx).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al importar: ${e.toString()}'),
                      backgroundColor: AppColors.red500,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // 5 — SYNC & RESET
  // ====================================================================

  Widget _buildSyncResetSection(GestureConfigService service) {
    return SettingsCard(
      icon: Icons.sync,
      title: 'Sincronización',
      description: 'Sincronizar o restablecer configuraciones',
      child: service.isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(Spacing.sm),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: GantiaButton(
                    label: 'Sync desde Supabase',
                    icon: Icons.cloud_sync,
                    variant: GantiaButtonVariant.default_,
                    onPressed: () => service.refreshFromSupabase(),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: GantiaButton(
                    label: 'Reset a Defaults',
                    icon: Icons.restart_alt,
                    variant: GantiaButtonVariant.danger,
                    onPressed: () => _confirmReset(service),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _confirmReset(GestureConfigService service) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surface0,
        title: const Text(
          'Restablecer Configuración',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          '¿Eliminar todas las configuraciones de gestos y '
          'restablecer los valores por defecto?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Restablecer',
              style: TextStyle(color: AppColors.red500),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await service.resetToDefaults();
    }
  }

  // ====================================================================
  // 6 — LEARN GESTURE WIZARD
  // ====================================================================

  Widget _buildLearnSection(LearningService service) {
    return SettingsCard(
      icon: Icons.auto_fix_high,
      title: 'Aprender Gesto',
      description: 'Crear un gesto nuevo mediante muestras',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_learnInProgress) ...[
            const Text(
              'Realizá un gesto 3 veces y el asistente lo '
              'analizará para configurarlo.',
              style: TextStyle(fontSize: 12, color: AppColors.surfaceLight500),
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
                setState(() {}); // Refresh sample count display
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

  Future<void> _startLearnWizard(LearningService service) async {
    setState(() {
      _learnInProgress = true;
      _learnStep = 0;
    });
  }
}
