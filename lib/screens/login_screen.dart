import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme/context_extensions.dart';
import '../theme/shadows.dart';
import '../theme/spacing.dart';
import '../widgets/gantia_button.dart';
import '../widgets/gantia_form_field.dart';
import '../widgets/gantia_scramble_text.dart';

final _emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onRegisterTap;

  const LoginScreen({super.key, required this.authService, this.onLoginSuccess, this.onRegisterTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.authService.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (success && mounted) {
      widget.onLoginSuccess?.call();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.authService.error ?? 'Error al iniciar sesión'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showServerConfigDialog(BuildContext context, WidgetRef ref) {
    final config = ref.read(serverConfigProvider);
    final hostCtrl = TextEditingController(text: config.host);
    final portCtrl = TextEditingController(text: config.port.toString());
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Configuración Servidor'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: hostCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Host',
                    hintText: '192.168.1.100',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Host requerido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: portCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Puerto',
                    hintText: '8000',
                    border: OutlineInputBorder(),
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
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final host = hostCtrl.text.trim();
                final port = int.parse(portCtrl.text.trim());
                await ref.read(serverConfigProvider).setHostPort(host, port);
                ref.read(apiServiceProvider).setBaseUrl('http://$host:$port');
                ref.invalidate(wsClientProvider);
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  hostCtrl.dispose();
                  portCtrl.dispose();
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Servidor: $host:$port'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      hostCtrl.dispose();
      portCtrl.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surface50,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Container(
                width: 420,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
                decoration: BoxDecoration(
                  color: context.surface0,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: GantiaShadows.elevated(context.surface900, context.surface0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer(
                      builder: (context, ref, _) {
                        return GestureDetector(
                          onLongPress: () => _showServerConfigDialog(context, ref),
                          child: Image.asset(
                            'assets/logos/logo.webp',
                            width: 64,
                            height: 64,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: Spacing.lg),
                    GantiaScrambleText(
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        color: context.surface900,
                      ),
                    ),
                    const SizedBox(height: Spacing.xxxl),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          GantiaFormField(
                            label: 'Email',
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: [AutofillHints.email],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Email requerido';
                              if (!_emailRegex.hasMatch(v.trim())) return 'Email inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: Spacing.xl),
                          GantiaFormField(
                            label: 'Contraseña',
                            controller: _passwordCtrl,
                            obscure: _obscurePassword,
                            autofillHints: [AutofillHints.password],
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Contraseña requerida';
                              return null;
                            },
                            suffix: Tooltip(
                              message: _obscurePassword
                                  ? 'Mostrar contraseña'
                                  : 'Ocultar contraseña',
                              child: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 18,
                                  color: context.surface500,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: Spacing.xl),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Funcionalidad en desarrollo'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.surface500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: Spacing.sm),
                          SizedBox(
                            width: double.infinity,
                            child: ListenableBuilder(
                              listenable: widget.authService,
                              builder: (context, _) {
                                return GantiaButton(
                                  label: 'INGRESAR',
                                  variant: GantiaButtonVariant.primary,
                                  expanded: true,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15),
                                  isLoading: widget.authService.isLoading,
                                  onPressed: _submit,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: Spacing.lg),
                          TextButton(
                            onPressed: widget.onRegisterTap,
                            child: Text(
                              '¿No tenés cuenta? Registrate',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.surface500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
