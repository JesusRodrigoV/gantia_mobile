import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/shadows.dart';
import '../theme/spacing.dart';
import '../widgets/gantia_scramble_text.dart';

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
                                      'INGRESAR',
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
