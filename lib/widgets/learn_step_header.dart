import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';

class LearnStepHeader extends StatelessWidget {
  final String step;
  final String title;

  const LearnStepHeader({super.key, required this.step, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(step,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
            letterSpacing: 0.1, color: AppColors.primary500)),
        Text(title,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.surface700)),
      ],
    );
  }
}
