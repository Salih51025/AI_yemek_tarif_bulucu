/// Premium full-screen AI thinking: gradient, particles, staggered skeletons.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/localization/app_localizations.dart';

class PremiumAiOverlay extends StatefulWidget {
  const PremiumAiOverlay({super.key});

  static const messageCount = 4;

  @override
  State<PremiumAiOverlay> createState() => _PremiumAiOverlayState();
}

class _PremiumAiOverlayState extends State<PremiumAiOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _gradientCtrl;
  late final AnimationController _chefCtrl;
  int _msg = 0;
  Timer? _msgTimer;

  @override
  void initState() {
    super.initState();
    _gradientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _chefCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _msgTimer = Timer.periodic(const Duration(milliseconds: 2200), (_) {
      if (!mounted) return;
      setState(() => _msg = (_msg + 1) % PremiumAiOverlay.messageCount);
    });
  }

  @override
  void dispose() {
    _msgTimer?.cancel();
    _gradientCtrl.dispose();
    _chefCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final messages = [
      l10n.aiThinking1,
      l10n.aiThinking2,
      l10n.aiThinking3,
      l10n.aiThinking4,
    ];

    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _gradientCtrl,
        builder: (context, _) {
          final t = _gradientCtrl.value * 2 * math.pi;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(math.cos(t), -1),
                end: Alignment(-math.cos(t), 1),
                colors: isDark
                    ? [
                        const Color(0xFF121212).withValues(alpha: 0.97),
                        scheme.primary.withValues(alpha: 0.35),
                        const Color(0xFF1A1A1A).withValues(alpha: 0.97),
                      ]
                    : [
                        const Color(0xFFF7F4EF).withValues(alpha: 0.97),
                        scheme.secondary.withValues(alpha: 0.25),
                        scheme.primary.withValues(alpha: 0.15),
                      ],
              ),
            ),
            child: Stack(
              children: [
                const _FloatingParticles(),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        SizedBox(height: 48.h),
                        ScaleTransition(
                          scale: Tween<double>(begin: 0.94, end: 1.06).animate(
                            CurvedAnimation(parent: _chefCtrl, curve: Curves.easeInOut),
                          ),
                          child: Container(
                            width: 108.w,
                            height: 108.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [scheme.primary, scheme.secondary],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: scheme.primary.withValues(alpha: 0.4),
                                  blurRadius: 28,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.soup_kitchen_rounded,
                              size: 52.sp,
                              color: scheme.onPrimary,
                            ),
                          ),
                        ),
                        SizedBox(height: 28.h),
                        Text(
                          l10n.aiCookingTitle,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        SizedBox(height: 12.h),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 450),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.15),
                                end: Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                          ),
                          child: Text(
                            messages[_msg],
                            key: ValueKey(_msg),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.75),
                                ),
                          ),
                        ),
                        SizedBox(height: 40.h),
                        Expanded(
                          child: ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 4,
                            separatorBuilder: (_, __) => SizedBox(height: 14.h),
                            itemBuilder: (context, i) => _StaggerSkeleton(index: i),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StaggerSkeleton extends StatefulWidget {
  const _StaggerSkeleton({required this.index});

  final int index;

  @override
  State<_StaggerSkeleton> createState() => _StaggerSkeletonState();
}

class _StaggerSkeletonState extends State<_StaggerSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    Future<void>.delayed(Duration(milliseconds: 120 * widget.index), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        highlightColor: Theme.of(context).colorScheme.surface,
        child: Container(
          height: 96.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }
}

class _FloatingParticles extends StatelessWidget {
  const _FloatingParticles();

  static const _icons = [
    Icons.egg_alt_outlined,
    Icons.eco_outlined,
    Icons.local_pizza_outlined,
    Icons.ramen_dining_outlined,
    Icons.icecream_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: List.generate(8, (i) {
            final left = (i * 47.0) % constraints.maxWidth;
            final top = (i * 83.0) % (constraints.maxHeight * 0.6);
            return Positioned(
              left: left,
              top: top,
              child: Icon(
                _icons[i % _icons.length],
                size: 18 + (i % 3) * 4,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.12 + (i % 3) * 0.04),
              ),
            );
          }),
        );
      },
    );
  }
}
