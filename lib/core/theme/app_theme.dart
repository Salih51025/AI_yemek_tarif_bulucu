/// Application theme configuration using Material Design 3.
///
/// Provides centralized theme management with support for
/// light/dark modes, custom colors, and responsive typography.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'semantic_colors.dart';
import 'design_tokens.dart';

/// Application color palette - Premium Design System.
///
/// Color Philosophy:
/// - Primary (Deep Avocado Green): Represents fresh food, health, and intelligent automation
/// - Secondary (Warm Saffron Orange): Stimulates appetite, triggers actions, highlights CTAs
/// - Background: Ultra-clean dark slate accents and soft off-white surfaces
class AppColors {
  AppColors._();

  // Primary colors - Deep Avocado Green
  static const Color primary = Color(0xFF1B4332);
  static const Color primaryDark = Color(0xFF081C15);
  static const Color primaryLight = Color(0xFF40916C);
  static const Color primaryAccent = Color(0xFF52B788);

  // Secondary colors - Warm Saffron Orange
  static const Color secondary = Color(0xFFF77F00);
  static const Color secondaryDark = Color(0xFFD65A00);
  static const Color secondaryLight = Color(0xFFFCBF49);
  static const Color secondaryAccent = Color(0xFFFFB703);

  // Neutral colors - warm light surfaces
  static const Color background = Color(0xFFF7F4EF);
  static const Color surface = Color(0xFFFFFCF8);
  static const Color surfaceVariant = Color(0xFFF0EDE8);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);

  // Dark slate accents
  static const Color darkSlate = Color(0xFF1E293B);
  static const Color darkSlateLight = Color(0xFF334155);
  static const Color darkSlateLighter = Color(0xFF475569);

  // Text colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Divider and border
  static const Color divider = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFCBD5E1);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Overlay colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
}

/// Dark theme color palette - Premium Design System.
class AppDarkColors {
  AppDarkColors._();

  // Material dark (#121212 family) — not pure black
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2A2A2A);

  // Primary colors in dark mode - Lighter avocado green
  static const Color primary = Color(0xFF40916C);
  static const Color primaryLight = Color(0xFF52B788);

  // Secondary colors in dark mode - Lighter saffron orange
  static const Color secondary = Color(0xFFFCBF49);
  static const Color secondaryLight = Color(0xFFFFB703);

  // Text colors in dark mode — soft hierarchy
  static const Color textPrimary = Color(0xFFE8EAED);
  static const Color textSecondary = Color(0xFFB0B6BF);
  static const Color textHint = Color(0xFF7A828E);

  // Divider and border in dark mode
  static const Color divider = Color(0xFF334155);
  static const Color border = Color(0xFF475569);
}

/// Application text styles using Google Fonts - Premium Typography System.
///
/// Font Family: Outfit (modern, geometric, highly readable)
/// Hierarchy: Clear visual hierarchy with consistent spacing and weight
class AppTextStyles {
  AppTextStyles._();

  // Headline styles - For major headings and titles
  static TextStyle get headlineLarge => GoogleFonts.outfit(
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get headlineMedium => GoogleFonts.outfit(
        fontSize: 28.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.25,
      );

  static TextStyle get headlineSmall => GoogleFonts.outfit(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // Title styles - For section headers and card titles
  static TextStyle get titleLarge => GoogleFonts.outfit(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.outfit(
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleSmall => GoogleFonts.outfit(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  // Body styles - For main content text
  static TextStyle get bodyLarge => GoogleFonts.outfit(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.outfit(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.outfit(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // Label styles - For buttons, tags, and small UI elements
  static TextStyle get labelLarge => GoogleFonts.outfit(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.25,
      );

  static TextStyle get labelMedium => GoogleFonts.outfit(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.25,
      );

  static TextStyle get labelSmall => GoogleFonts.outfit(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      );

  // Caption styles - For helper text and metadata
  static TextStyle get caption => GoogleFonts.outfit(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textHint,
      );

  // Custom styles for specific use cases
  static TextStyle get button => GoogleFonts.outfit(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle get overline => GoogleFonts.outfit(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 1.5,
      );
}

/// Light theme configuration - Premium Material Design 3.
ThemeData get lightTheme {
  return ThemeData(
    useMaterial3: true,
    extensions: const [SemanticColors.light],
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.titleLarge,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: AppElevation.md,
      shadowColor: AppColors.overlayLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.lg.r),
      ),
      margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm.w, vertical: AppSpacing.xxs.h),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg.w, vertical: AppSpacing.sm.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md.r),
        ),
        elevation: AppElevation.md,
        textStyle: AppTextStyles.button,
        animationDuration: AppDuration.normal,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        textStyle: AppTextStyles.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 2),
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        textStyle: AppTextStyles.button,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
      selectedLabelStyle: AppTextStyles.labelSmall,
      unselectedLabelStyle: AppTextStyles.labelSmall,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    iconTheme: const IconThemeData(color: AppColors.textPrimary),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),
  );
}

/// Dark theme configuration - Premium Material Design 3.
ThemeData get darkTheme {
  return ThemeData(
    useMaterial3: true,
    extensions: const [SemanticColors.dark],
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppDarkColors.primary,
      brightness: Brightness.dark,
      primary: AppDarkColors.primary,
      secondary: AppDarkColors.secondary,
      surface: AppDarkColors.surface,
      background: AppDarkColors.background,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppDarkColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppDarkColors.surface,
      foregroundColor: AppDarkColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: AppDarkColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: AppDarkColors.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: AppDarkColors.surface,
      elevation: 2,
      shadowColor: AppColors.overlayLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppDarkColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 2,
        textStyle: AppTextStyles.button,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppDarkColors.primary,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        textStyle: AppTextStyles.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppDarkColors.primary,
        side: const BorderSide(color: AppDarkColors.primary, width: 2),
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        textStyle: AppTextStyles.button,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppDarkColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: AppDarkColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: AppDarkColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: AppDarkColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      hintStyle:
          AppTextStyles.bodyMedium.copyWith(color: AppDarkColors.textHint),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppDarkColors.secondary,
      foregroundColor: AppColors.textPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppDarkColors.surface,
      selectedItemColor: AppDarkColors.primary,
      unselectedItemColor: AppDarkColors.textHint,
      selectedLabelStyle: AppTextStyles.labelSmall,
      unselectedLabelStyle: AppTextStyles.labelSmall,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    iconTheme: const IconThemeData(color: AppDarkColors.textPrimary),
    dividerTheme: const DividerThemeData(
      color: AppDarkColors.divider,
      thickness: 1,
      space: 1,
    ),
  );
}
