import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import '../widgets/gantia_button.dart';
import '../widgets/settings_card.dart';

class ImportExportSection extends ConsumerStatefulWidget {
  const ImportExportSection({super.key});

  @override
  ConsumerState<ImportExportSection> createState() =>
      _ImportExportSectionState();
}

class _ImportExportSectionState extends ConsumerState<ImportExportSection> {
  final _importTextController = TextEditingController();

  @override
  void dispose() {
    _importTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(gestureConfigServiceProvider);

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

    showDialog<void>(
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
                  Clipboard.setData(ClipboardData(text: json));
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

    showDialog<void>(
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
              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(ctx);

              try {
                final decoded = jsonDecode(text);
                List<Map<String, dynamic>> configs;
                if (decoded is List) {
                  configs = decoded.cast<Map<String, dynamic>>();
                } else {
                  configs = [decoded as Map<String, dynamic>];
                }
                await service.importConfigs(configs);
                nav.pop();
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
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
}
