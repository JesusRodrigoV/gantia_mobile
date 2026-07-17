import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gesture_config_model.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../widgets/gantia_button.dart';
import '../widgets/gesture_config_dialog.dart';
import '../widgets/gesture_config_row.dart';
import '../widgets/settings_card.dart';
import '../widgets/skeleton_card.dart';

class GestureConfigSection extends ConsumerStatefulWidget {
  const GestureConfigSection({super.key});

  @override
  ConsumerState<GestureConfigSection> createState() => _GestureConfigSectionState();
}

class _GestureConfigSectionState extends ConsumerState<GestureConfigSection> {
  String _selectedContext = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gestureConfigServiceProvider).getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(gestureConfigServiceProvider);

    return SettingsCard(
      icon: Icons.gesture,
      title: 'Gestos Configurados',
      description: 'Acciones asignadas a cada gesto manual',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContextFilter(),
          const SizedBox(height: Spacing.sm),
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
        separatorBuilder: (_, _) => const SizedBox(width: Spacing.xs),
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
        : service.configs.where((c) => c.context == _selectedContext).toList();

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
        ...filtered.map((config) => GestureConfigRow(
              config: config,
              onEdit: () => showGestureConfigDialog(context, ref, existing: config),
              onDelete: () => _confirmDelete(config),
            )),
        const SizedBox(height: Spacing.sm),
        GantiaButton(
          label: 'Agregar Gesto',
          icon: Icons.add,
          variant: GantiaButtonVariant.primary,
          onPressed: () => showGestureConfigDialog(context, ref),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(GestureConfig config) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surface0,
        title: const Text('Eliminar Gesto', style: TextStyle(fontWeight: FontWeight.w700)),
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
            child: const Text('Eliminar', style: TextStyle(color: AppColors.red500)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(gestureConfigServiceProvider).delete(config.id);
    }
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    dev.log('[GestureConfigSection] $error');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
      child: Column(
        children: [
          Icon(Icons.cloud_off, color: AppColors.amber600, size: 32),
          const SizedBox(height: Spacing.sm),
          Text(
            'No se pudieron cargar las configuraciones',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.surface700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Verificá la conexión e intentá de nuevo.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: context.surface500),
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
}
