import 'package:flutter/material.dart';

class PasswordVisibilityIcon extends StatelessWidget {
  final bool obscure;
  final VoidCallback onToggle;

  const PasswordVisibilityIcon({super.key, required this.obscure, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
      child: IconButton(
        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, size: 18),
        onPressed: onToggle,
      ),
    );
  }
}
