import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/shadows.dart';
import '../models/action_message.dart';

class GestureFlash extends StatefulWidget {
  final GestureDetectedEvent? event;

  const GestureFlash({super.key, this.event});

  @override
  State<GestureFlash> createState() => _GestureFlashState();
}

class _GestureFlashState extends State<GestureFlash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _fadeScaleIn;
  late CurvedAnimation _fadeScaleOut;
  GestureDetectedEvent? _current;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _fadeScaleIn = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _fadeScaleOut = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    if (widget.event != null) {
      _current = widget.event;
      _controller.forward();
    }
  }

  @override
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

  @override
  void dispose() {
    _fadeScaleIn.dispose();
    _fadeScaleOut.dispose();
    _controller.dispose();
    super.dispose();
  }

  Color _bgColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.surfaceDark0 : AppColors.surfaceLight0;
  }

  Color _textColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.surfaceDark800 : AppColors.surfaceLight800;
  }

  bool _getIsDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    if (_current == null) return const SizedBox.shrink();

    if (MediaQuery.of(context).disableAnimations) {
      return _buildCard(context);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final isReversing = _controller.status == AnimationStatus.reverse;
        final curve = isReversing ? _fadeScaleOut : _fadeScaleIn;
        final scale = Tween<double>(
          begin: isReversing ? 0.95 : 0.92,
          end: 1.0,
        ).evaluate(curve);

        return Opacity(
          opacity: curve.value,
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final isDark = _getIsDark(context);
    final surface900 = isDark ? AppColors.surfaceDark900 : AppColors.surfaceLight900;
    final surface0 = isDark ? AppColors.surfaceDark0 : AppColors.surfaceLight0;

    return Semantics(
      label: 'Gesto detectado: ${_current!.gesture} → ${getActionLabel(_current!.action)}',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: _bgColor(context),
              borderRadius: BorderRadius.circular(14),
              boxShadow: GantiaShadows.elevated(surface900, surface0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _current!.gesture,
                  style: GoogleFonts.cormorantGaramond(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: _textColor(context),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\u2192',
                  style: GoogleFonts.notoSans(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    color: _textColor(context).withAlpha(150),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  getActionLabel(_current!.action),
                  style: GoogleFonts.notoSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: _textColor(context),
                  ),
                ),
              ],
            ),
          ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFc9a94e).withAlpha(200),
                  const Color(0xFFc9a94e),
                  const Color(0xFFc9a94e).withAlpha(200),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Text(
              '\u03B3',
              style: GoogleFonts.cormorantGaramond(
                fontWeight: FontWeight.w700,
                fontSize: 64,
                color: const Color(0xFFc9a94e).withAlpha(20),
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }
}
