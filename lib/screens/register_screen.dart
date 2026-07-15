import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/context_extensions.dart';
import '../theme/shadows.dart';
import '../theme/spacing.dart';
import '../widgets/gantia_button.dart';
import '../widgets/gantia_form_field.dart';
import '../widgets/gantia_scramble_text.dart';

final _emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');

class RegisterScreen extends StatefulWidget {
  final AuthService authService;
  final VoidCallback? onRegisterSuccess;
  final VoidCallback? onBackToLogin;

  const RegisterScreen({
    super.key,
    required this.authService,
    this.onRegisterSuccess,
    this.onBackToLogin,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.authService.register(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (success && mounted) {
      widget.onRegisterSuccess?.call();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.authService.error ?? 'Error al registrarse'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
                  boxShadow: GantiaShadows.inset(
                      context.surface900, context.surface0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/logos/logo.webp',
                      width: 64,
                      height: 64,
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
                    const SizedBox(height: Spacing.sm),
                    Text(
                      'CREAR CUENTA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        color: context.surface500,
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
                              if (v == null || v.trim().isEmpty) {
                                return 'Email requerido';
                              }
                              if (!_emailRegex.hasMatch(v.trim())) {
                                return 'Email inválido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: Spacing.xl),
                          GantiaFormField(
                            label: 'Contraseña',
                            controller: _passwordCtrl,
                            obscure: _obscurePassword,
                            autofillHints: [AutofillHints.newPassword],
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Contraseña requerida';
                              }
                              if (v.length < 6) return 'Mínimo 6 caracteres';
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
                          GantiaFormField(
                            label: 'Confirmar Contraseña',
                            controller: _confirmCtrl,
                            obscure: _obscureConfirm,
                            autofillHints: [AutofillHints.newPassword],
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Confirmá la contraseña';
                              }
                              if (v != _passwordCtrl.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                            suffix: Tooltip(
                              message: _obscureConfirm
                                  ? 'Mostrar contraseña'
                                  : 'Ocultar contraseña',
                              child: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 18,
                                  color: context.surface500,
                                ),
                                onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                          ),
                          const SizedBox(height: Spacing.xxxl - 6),
                          SizedBox(
                            width: double.infinity,
                            child: ListenableBuilder(
                              listenable: widget.authService,
                              builder: (context, _) {
                                return GantiaButton(
                                  label: 'CREAR CUENTA',
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
                            onPressed: widget.onBackToLogin,
                            child: Text(
                              '¿Ya tenés cuenta? Iniciá sesión',
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
