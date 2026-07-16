import 'dart:convert';
import 'package:flutter/material.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import 'gantia_button.dart';

class ImportDialog extends StatefulWidget {
  final GestureConfigService service;

  const ImportDialog({super.key, required this.service});

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.surface0,
      title: const Text('Importar Configuración', style: TextStyle(fontWeight: FontWeight.w700)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pegá el JSON de configuración exportado:',
              style: TextStyle(fontSize: 12, color: context.surface500)),
            const SizedBox(height: Spacing.sm),
            TextField(
              controller: _controller,
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
              style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: context.surface700),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar', style: TextStyle(color: context.surface500))),
        GantiaButton(
          label: 'Importar',
          variant: GantiaButtonVariant.primary,
          onPressed: () async {
            final text = _controller.text.trim();
            if (text.isEmpty) return;
            final messenger = ScaffoldMessenger.of(context);
            final nav = Navigator.of(context);
            try {
              final decoded = jsonDecode(text);
              final configs = decoded is List
                  ? decoded.cast<Map<String, dynamic>>()
                  : [decoded as Map<String, dynamic>];
              await widget.service.importConfigs(configs);
              if (nav.context.mounted) nav.pop();
            } catch (e) {
              if (mounted) {
                messenger.showSnackBar(SnackBar(
                  content: Text('Error al importar: $e'),
                  backgroundColor: AppColors.red500,
                ));
              }
            }
          },
        ),
      ],
    );
  }
}
