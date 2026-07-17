import 'package:flutter/material.dart';
import '../theme/context_extensions.dart';
import '../theme/shadows.dart';

class SkeletonCard extends StatefulWidget {
  final double height;
  final int lines;
  final EdgeInsetsGeometry? margin;

  const SkeletonCard({
    super.key,
    this.height = 120,
    this.lines = 3,
    this.margin,
  });

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) => Opacity(opacity: _opacity.value, child: child),
      child: Container(
        margin: widget.margin,
        decoration: BoxDecoration(
          color: context.surface50,
          borderRadius: BorderRadius.circular(16),
          boxShadow: GantiaShadows.inset(Theme.of(context).brightness),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(widget.lines, (i) {
              return Padding(
                padding: EdgeInsets.only(bottom: i < widget.lines - 1 ? 12 : 0),
                child: Container(
                  height: 12,
                  width: i == widget.lines - 1 ? 0.4 : 1.0,
                  decoration: BoxDecoration(
                    color: context.surface200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class SkeletonBar extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonBar({
    super.key,
    this.width = double.infinity,
    this.height = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.surface200,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
