/// Premium route transitions (fade + subtle scale).
library;

import 'package:flutter/material.dart';

enum AppTransition { fade, slideUp, scale }

class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({
    required Widget page,
    AppTransition transition = AppTransition.fade,
    Duration duration = const Duration(milliseconds: 320),
    super.settings,
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return switch (transition) {
              AppTransition.slideUp => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(curve),
                  child: FadeTransition(opacity: curve, child: child),
                ),
              AppTransition.scale => FadeTransition(
                  opacity: curve,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.96, end: 1).animate(curve),
                    child: child,
                  ),
                ),
              AppTransition.fade => FadeTransition(opacity: curve, child: child),
            };
          },
        );
}
