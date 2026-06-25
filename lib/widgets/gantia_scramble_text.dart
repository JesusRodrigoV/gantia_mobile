import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class GantiaScrambleText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final String chars;

  const GantiaScrambleText({
    super.key,
    this.text = 'Gantia',
    this.style,
    this.chars = 'γαντιαμπωψχφυυ',
  });

  @override
  State<GantiaScrambleText> createState() => _GantiaScrambleTextState();
}

class _GantiaScrambleTextState extends State<GantiaScrambleText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  String _displayText = '';
  int _revealedCount = 0;
  Timer? _scrambleTimer;
  final _rng = Random();
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _displayText = _randomChars(widget.text.length);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.addStatusListener(_onAnimationEnd);
    _startScramble();
    _controller.forward();
  }

  void _onAnimationEnd(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_disposed) {
      _scrambleTimer?.cancel();
      setState(() => _displayText = widget.text);
    }
  }

  void _startScramble() {
    const revealDelayMs = 200;
    final total = widget.text.length;
    final revealInterval = ((1500 - revealDelayMs) / total).round();

    _scrambleTimer = Timer.periodic(const Duration(milliseconds: 40), (t) {
      if (_disposed) return;
      final elapsed = t.tick * 40;

      if (elapsed >= revealDelayMs) {
        final revealed =
            ((elapsed - revealDelayMs) / revealInterval).floor().clamp(0, total);
        if (revealed > _revealedCount) _revealedCount = revealed;
      }

      setState(() {
        _displayText = String.fromCharCodes(
          List.generate(total, (i) {
            if (i < _revealedCount) return widget.text.codeUnitAt(i);
            return widget.chars.codeUnitAt(
              _rng.nextInt(widget.chars.length),
            );
          }),
        );
      });
    });
  }

  String _randomChars(int length) {
    return List.generate(
      length,
      (_) => widget.chars[_rng.nextInt(widget.chars.length)],
    ).join();
  }

  @override
  void dispose() {
    _disposed = true;
    _scrambleTimer?.cancel();
    _controller.removeStatusListener(_onAnimationEnd);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Text(_displayText, style: widget.style),
    );
  }
}
