import 'package:flutter/material.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import 'gantia_button.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (details) {
      if (mounted) {
        setState(() => _error = details.exception);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: context.surface500),
              const SizedBox(height: Spacing.md),
              Text(
                'Ocurrió un error inesperado',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.surface700),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Cerrando la app y volviendo a abrirla puede solucionarlo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: context.surface500),
              ),
              const SizedBox(height: Spacing.lg),
              GantiaButton(
                label: 'Reintentar',
                icon: Icons.refresh,
                onPressed: () => setState(() => _error = null),
              ),
            ],
          ),
        ),
      );
    }
    return widget.child;
  }
}
