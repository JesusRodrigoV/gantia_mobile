import 'package:flutter/material.dart';
import '../services/glove_state.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';

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
            color: _dotColor(context),
            shape: BoxShape.circle,
            boxShadow: flowing ? _flowGlow : null,
          ),
        ),
      ),
    );
  }

  Color _dotColor(BuildContext context) {
    switch (status) {
      case ConnectionStatus.connected:
        return AppColors.primary500;
      case ConnectionStatus.connecting:
        return AppColors.primary300;
      case ConnectionStatus.reconnecting:
        return AppColors.warning500;
      case ConnectionStatus.disconnected:
      case ConnectionStatus.error:
        return context.surface400;
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
    if (status == ConnectionStatus.disconnected || status == ConnectionStatus.error) {
      return [
        BoxShadow(
          offset: const Offset(2, 2),
          blurRadius: 4,
          color: context.surface900.withAlpha(15),
        ),
        BoxShadow(
          offset: const Offset(-2, -2),
          blurRadius: 4,
          color: context.surface0.withAlpha(204),
        ),
      ];
    }

    return [
      BoxShadow(
        color: _dotColor(context).withAlpha(30),
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
        color: active ? AppColors.primary500 : context.surface500,
        boxShadow: active
            ? [BoxShadow(color: AppColors.primary500.withAlpha(50), blurRadius: 4)]
            : null,
      ),
    );
  }
}
