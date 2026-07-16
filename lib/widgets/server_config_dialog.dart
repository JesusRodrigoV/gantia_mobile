import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class ServerConfigDialog extends ConsumerStatefulWidget {
  const ServerConfigDialog({super.key});

  @override
  ConsumerState<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends ConsumerState<ServerConfigDialog> {
  late TextEditingController _hostCtrl;
  late TextEditingController _portCtrl;
  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    final config = ref.read(serverConfigProvider);
    _hostCtrl = TextEditingController(text: config.host);
    _portCtrl = TextEditingController(text: config.port.toString());
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _hostCtrl.dispose();
    _portCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configuración Servidor'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _hostCtrl,
              decoration: const InputDecoration(
                labelText: 'Host', hintText: '192.168.1.100', border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              validator: (v) => v == null || v.trim().isEmpty ? 'Host requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _portCtrl,
              decoration: const InputDecoration(
                labelText: 'Puerto', hintText: '8000', border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Puerto requerido';
                final n = int.tryParse(v);
                if (n == null || n < 1 || n > 65535) return 'Puerto inválido';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            final host = _hostCtrl.text.trim();
            final port = int.parse(_portCtrl.text.trim());
            await ref.read(serverConfigProvider).setHostPort(host, port);
            ref.read(apiServiceProvider).setBaseUrl('http://$host:$port');
            if (context.mounted) Navigator.of(context).pop();
            ref.invalidate(wsClientProvider);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Servidor: $host:$port'), behavior: SnackBarBehavior.floating),
              );
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
