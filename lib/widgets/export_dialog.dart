import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import 'gantia_button.dart';

class ExportDialog extends StatelessWidget {
  final String jsonContent;

  const ExportDialog({super.key, required this.jsonContent});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.surface0,
      title: const Text('Configuración Exportada', style: TextStyle(fontWeight: FontWeight.w700)),
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
              decoration: BoxDecoration(color: context.surface100, borderRadius: BorderRadius.circular(8)),
              child: SingleChildScrollView(
                child: SelectableText(jsonContent,
                  style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: context.surface700)),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            GantiaButton(
              label: 'Copiar al Portapapeles',
              icon: Icons.copy,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonContent));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copiado al portapapeles')));
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar')),
      ],
    );
  }
}
