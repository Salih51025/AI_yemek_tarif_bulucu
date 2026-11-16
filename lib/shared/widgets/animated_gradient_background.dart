/// Subtle animated gradient mesh for premium screens.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({required this.child, super.key});

  final Widget child;

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value * 2 * math.pi;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(math.cos(t), math.sin(t)),
              end: Alignment(-math.cos(t), -math.sin(t)),
              colors: isDark
                  ? [
                      const Color(0xFF121212),
                      scheme.primary.withValues(alpha: 0.18),
                      const Color(0xFF1A1A1A),
                    ]
                  : [
                      const Color(0xFFF7F4EF),
                      scheme.secondary.withValues(alpha: 0.12),
                      const Color(0xFFF0EDE8),
                    ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
