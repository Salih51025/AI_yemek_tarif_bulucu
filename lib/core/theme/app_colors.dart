/// Premium Color System
///
/// Enterprise-grade color palette with semantic naming,
/// accessibility support, and dark mode variants.
library;

import 'package:flutter/material.dart';

// ============================================================================
// PRIMARY BRAND COLORS
// ============================================================================

class AppColors {
  // Primary brand color (warm orange for food appetite)
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF9A6B);
  static const Color primaryDark = Color(0xFFCC5629);
  
  // Secondary brand color (fresh green for health)
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryLight = Color(0xFF81C784);
  static const Color secondaryDark = Color(0xFF388E3C);
  
  // Accent color (vibrant blue for trust)
  static const Color accent = Color(0xFF2196F3);
  static const Color accentLight = Color(0xFF64B5F6);
  static const Color accentDark = Color(0xFF1976D2);
}

// ============================================================================
// NEUTRAL COLORS
// ============================================================================

class NeutralColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  // Gray scale
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);
}

// ============================================================================
// SEMANTIC COLORS
// ============================================================================

class SemanticColors {
  // Success
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color successDark = Color(0xFF2E7D32);
  
  // Warning
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color warningDark = Color(0xFFF57C00);
  
  // Error
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color errorDark = Color(0xFFD32F2F);
  
  // Info
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);
  static const Color infoDark = Color(0xFF1976D2);
}

// ============================================================================
// FOOD CATEGORY COLORS
// ============================================================================

class FoodCategoryColors {
  static const Color breakfast = Color(0xFFFFB74D);
  static const Color lunch = Color(0xFF4DB6AC);
  static const Color dinner = Color(0xFFE57373);
  static const Color snack = Color(0xFFBA68C8);
  static const Color dessert = Color(0xFFF06292);
}

// ============================================================================
// DIFFICULTY COLORS
// ============================================================================

class DifficultyColors {
  static const Color easy = Color(0xFF66BB6A);
  static const Color medium = Color(0xFFFFA726);
  static const Color hard = Color(0xFFEF5350);
}

// ============================================================================
// DARK MODE COLORS
// ============================================================================

class DarkModeColors {
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2C2C2C);
  static const Color onBackground = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFE0E0E0);
  static const Color onSurfaceVariant = Color(0xFFB0B0B0);
}

// ============================================================================
// AMOLED DARK MODE COLORS
// ============================================================================

class AmoledDarkColors {
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF0A0A0A);
  static const Color surfaceVariant = Color(0xFF141414);
  static const Color onBackground = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFE0E0E0);
  static const Color onSurfaceVariant = Color(0xFFB0B0B0);
}

// ============================================================================
// GRADIENTS
// ============================================================================

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [AppColors.secondary, AppColors.secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [AppColors.accent, AppColors.accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFFB347)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient coolGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color.fromRGBO(255, 255, 255, 0.1),
      Color.fromRGBO(255, 255, 255, 0.05),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Color.fromRGBO(255, 255, 255, 0.0),
      Color.fromRGBO(255, 255, 255, 0.3),
      Color.fromRGBO(255, 255, 255, 0.0),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
  );
}
