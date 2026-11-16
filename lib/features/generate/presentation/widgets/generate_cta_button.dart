/// Premium generate CTA with scale + haptic.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/app_localizations.dart';

class GenerateCtaButton extends StatefulWidget {
  const GenerateCtaButton({
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  State<GenerateCtaButton> createState() => _GenerateCtaButtonState();
}

class _GenerateCtaButtonState extends State<GenerateCtaButton> {
  bool _pressed = false;

  void _handleTap() {
    if (widget.onPressed == null || widget.isLoading) return;
    HapticFeedback.mediumImpact();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTapDown: widget.isLoading ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.isLoading ? null : (_) => setState(() => _pressed = false),
      onTapCancel: widget.isLoading ? null : () => setState(() => _pressed = false),
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              colors: widget.isLoading
                  ? [scheme.outline, scheme.outline]
                  : [scheme.primary, scheme.secondary],
            ),
            boxShadow: widget.isLoading
                ? null
                : [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: scheme.onPrimary,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, color: scheme.onPrimary, size: 22.sp),
                      SizedBox(width: 10.w),
                      Text(
                        l10n.generateButton,
                        style: TextStyle(
                          color: scheme.onPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
