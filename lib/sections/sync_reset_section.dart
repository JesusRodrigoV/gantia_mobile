import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/gantia_button.dart';
import '../widgets/settings_card.dart';

class SyncResetSection extends ConsumerWidget {
  const SyncResetSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(gestureConfigServiceProvider);

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
          : Column(
              children: [
                GantiaButton(
                  label: 'Sync desde Supabase',
                  icon: Icons.cloud_sync,
                  variant: GantiaButtonVariant.default_,
                  expanded: true,
                  onPressed: () => _syncFromSupabase(context, ref, service),
                ),
                const SizedBox(height: Spacing.sm),
                GantiaButton(
                  label: 'Reset a Defaults',
                  icon: Icons.restart_alt,
                  variant: GantiaButtonVariant.danger,
                  expanded: true,
                  onPressed: () => _confirmReset(context, ref, service),
                ),
              ],
            ),
    );
  }

  Future<void> _syncFromSupabase(
    BuildContext context,
    WidgetRef ref,
    GestureConfigService service,
  ) async {
    final success = await service.refreshFromSupabase();
    if (!context.mounted) return;
    _showResult(context, success, service.error,
        'Configuraciones sincronizadas correctamente');
  }

  Future<void> _confirmReset(
    BuildContext context,
    WidgetRef ref,
    GestureConfigService service,
  ) async {
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
      final success = await service.resetToDefaults();
      if (!context.mounted) return;
      _showResult(context, success, service.error,
          'Configuraciones restablecidas correctamente');
    }
  }

  void _showResult(
    BuildContext context,
    bool success,
    String? error,
    String successMessage,
  ) {
    if (success) {
      showSuccessSnackBar(context, successMessage);
    } else {
      showErrorSnackBar(context, error ?? 'Error desconocido');
    }
  }
}
