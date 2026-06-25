import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/shadows.dart';
import '../theme/spacing.dart';
import '../widgets/gantia_scramble_text.dart';

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
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.authService.register(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro exitoso — ahora iniciá sesión'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Container(
            width: 420,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
            decoration: BoxDecoration(
              color: context.surface0,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: context.surface900.withAlpha(15),
                  blurRadius: 16,
                  offset: const Offset(8, 8),
                ),
                BoxShadow(
                  color: context.surface0.withAlpha(204),
                  blurRadius: 16,
                  offset: const Offset(-8, -8),
                ),
              ],
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
                      _buildField(
                        label: 'Email',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Email requerido';
                          if (!v.contains('@')) return 'Email inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: Spacing.xl),
                      _buildField(
                        label: 'Contraseña',
                        controller: _passwordCtrl,
                        obscure: _obscurePassword,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Contraseña requerida';
                          if (v.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            size: 18,
                            color: context.surface500,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      const SizedBox(height: Spacing.xl),
                      _buildField(
                        label: 'Confirmar Contraseña',
                        controller: _confirmCtrl,
                        obscure: _obscureConfirm,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Confirmá la contraseña';
                          if (v != _passwordCtrl.text) return 'Las contraseñas no coinciden';
                          return null;
                        },
                        suffix: IconButton(
                          icon: Icon(
                            _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                            size: 18,
                            color: context.surface500,
                          ),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      const SizedBox(height: Spacing.xxxl - 6),
                      SizedBox(
                        width: double.infinity,
                        child: ListenableBuilder(
                          listenable: widget.authService,
                          builder: (context, _) {
                            return ElevatedButton(
                              onPressed: widget.authService.isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.surface0,
                                foregroundColor: AppColors.primary600,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                shadowColor: Colors.transparent,
                              ),
                              child: widget.authService.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text(
                                      'CREAR CUENTA',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2,
                                      ),
                                    ),
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
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscure = false,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: context.surface500,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Container(
          decoration: BoxDecoration(
            color: context.surface50,
            borderRadius: BorderRadius.circular(12),
            boxShadow: GantiaShadows.insetSm(context.surface900, context.surface0),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            validator: validator,
            style: TextStyle(
              fontSize: 15,
              color: context.surface800,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm + 2),
              suffixIcon: suffix,
            ),
          ),
        ),
      ],
    );
  }
}
