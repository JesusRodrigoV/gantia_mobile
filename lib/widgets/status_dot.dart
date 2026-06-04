import 'package:flutter/material.dart';
import '../services/ws_service.dart';
import '../theme/app_colors.dart';

class StatusDot extends StatelessWidget {
  final ConnectionStatus status;
  final bool flowing;
  final double size;

  const StatusDot({
    super.key,
    required this.status,
    this.flowing = false,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size + 26,
      height: size + 26,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        boxShadow: _buildShadow(context),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _dotColor,
            shape: BoxShape.circle,
            boxShadow: flowing ? _flowGlow : null,
          ),
        ),
      ),
    );
  }

  Color get _dotColor {
    switch (status) {
      case ConnectionStatus.connected:
        return AppColors.primary500;
      case ConnectionStatus.connecting:
        return AppColors.primary300;
      case ConnectionStatus.disconnected:
      case ConnectionStatus.error:
        return AppColors.surfaceLight300;
    }
  }

  List<BoxShadow>? get _flowGlow => [
        BoxShadow(
          color: AppColors.primary500.withAlpha(60),
          blurRadius: 8,
          spreadRadius: 2,
        ),
      ];

  List<BoxShadow>? _buildShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface0 = isDark ? AppColors.surfaceDark0 : AppColors.surfaceLight0;
    final surface900 = isDark ? AppColors.surfaceDark900 : AppColors.surfaceLight900;

    if (status == ConnectionStatus.disconnected || status == ConnectionStatus.error) {
      return [
        const BoxShadow(
          offset: Offset(2, 2),
          blurRadius: 4,
          color: Color(0x0F000000),
        ),
        BoxShadow(
          offset: const Offset(-2, -2),
          blurRadius: 4,
          color: surface0.withAlpha(204),
        ),
      ];
    }

    return [
      BoxShadow(
        color: _dotColor.withAlpha(30),
        blurRadius: 0,
        spreadRadius: 3,
      ),
    ];
  }
}

class StatusDotSmall extends StatelessWidget {
  final bool active;

  const StatusDotSmall({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.primary500 : AppColors.surfaceLight400,
        boxShadow: active
            ? [BoxShadow(color: AppColors.primary500.withAlpha(50), blurRadius: 4)]
            : null,
      ),
    );
  }
}
