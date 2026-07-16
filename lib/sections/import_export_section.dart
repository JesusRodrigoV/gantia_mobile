import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../widgets/export_dialog.dart';
import '../widgets/gantia_button.dart';
import '../widgets/import_dialog.dart';
import '../widgets/settings_card.dart';

class ImportExportSection extends ConsumerStatefulWidget {
  const ImportExportSection({super.key});

  @override
  ConsumerState<ImportExportSection> createState() => _ImportExportSectionState();
}

class _ImportExportSectionState extends ConsumerState<ImportExportSection> {
  @override
  Widget build(BuildContext context) {
    final service = ref.watch(gestureConfigServiceProvider);

    return SettingsCard(
      icon: Icons.file_copy,
      title: 'Importar / Exportar',
      description: 'Respaldar o restaurar configuraciones',
      child: Row(children: [
        Expanded(
          child: GantiaButton(
            label: 'Exportar', icon: Icons.upload,
            onPressed: () => _handleExport(service),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GantiaButton(
            label: 'Importar', icon: Icons.download,
            onPressed: () => showDialog(
              context: context,
              builder: (_) => ImportDialog(service: service),
            ),
          ),
        ),
      ]),
    );
  }

  Future<void> _handleExport(GestureConfigService service) async {
    final json = await service.exportConfigs();
    if (json == null || !mounted) return;
    showDialog(context: context, builder: (_) => ExportDialog(jsonContent: json));
  }
}
