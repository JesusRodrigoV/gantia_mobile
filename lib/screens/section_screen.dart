import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';

class SectionScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const SectionScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surface50,
      appBar: AppBar(
        backgroundColor: context.surface0,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.surface700),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary500),
            const SizedBox(width: Spacing.xs),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.surface800,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(child: SingleChildScrollView(child: child)),
    );
  }
}
