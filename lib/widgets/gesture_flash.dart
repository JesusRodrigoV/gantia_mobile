import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/action_message.dart';

class GestureFlash extends StatefulWidget {
  final GestureDetectedEvent? event;

  const GestureFlash({super.key, this.event});

  State<GestureFlash> createState() => _GestureFlashState();
}

class _GestureFlashState extends State<GestureFlash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeSlide;
  GestureDetectedEvent? _current;

  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeSlide = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    if (widget.event != null) {
      _current = widget.event;
      _controller.forward();
    }
  }

  void didUpdateWidget(GestureFlash oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.event != null && widget.event != oldWidget.event) {
      _current = widget.event;
      _controller
        ..reset()
        ..forward();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _controller.reverse();
      });
    }
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    if (_current == null) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeSlide,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(_fadeSlide),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary500, AppColors.primary700],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary500.withAlpha(80),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.gesture, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                _current!.gesture,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Colors.white60, size: 18),
              const SizedBox(width: 8),
              Text(
                getActionLabel(_current!.action),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
