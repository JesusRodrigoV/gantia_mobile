import 'package:flutter/material.dart';
import '../theme/context_extensions.dart';
import '../theme/shadows.dart';
import '../theme/spacing.dart';

class GantiaFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscure;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final Iterable<String>? autofillHints;

  const GantiaFormField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscure = false,
    this.validator,
    this.suffix,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
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
            boxShadow: GantiaShadows.insetSm(
              context.surface900,
              context.surface0,
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            validator: validator,
            autofillHints: autofillHints?.toList(),
            style: TextStyle(
              fontSize: 15,
              color: context.surface800,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: suffix,
            ),
          ),
        ),
      ],
    );
  }
}
