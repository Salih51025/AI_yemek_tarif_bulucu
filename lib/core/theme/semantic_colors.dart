/// Semantic text & surface tokens — use via [Theme.of(context).extension].
library;

import 'package:flutter/material.dart';

@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  const SemanticColors({
    required this.primaryText,
    required this.secondaryText,
    required this.mutedText,
    required this.accentText,
    required this.cardSurface,
    required this.elevatedSurface,
  });

  final Color primaryText;
  final Color secondaryText;
  final Color mutedText;
  final Color accentText;
  final Color cardSurface;
  final Color elevatedSurface;

  static const light = SemanticColors(
    primaryText: Color(0xFF1A1D21),
    secondaryText: Color(0xFF5C6370),
    mutedText: Color(0xFF8B939E),
    accentText: Color(0xFF1B4332),
    cardSurface: Color(0xFFFFFFFF),
    elevatedSurface: Color(0xFFF5F3EF),
  );

  static const dark = SemanticColors(
    primaryText: Color(0xFFE8EAED),
    secondaryText: Color(0xFFB0B6BF),
    mutedText: Color(0xFF7A828E),
    accentText: Color(0xFF74C69D),
    cardSurface: Color(0xFF1E1E1E),
    elevatedSurface: Color(0xFF2A2A2A),
  );

  @override
  SemanticColors copyWith({
    Color? primaryText,
    Color? secondaryText,
    Color? mutedText,
    Color? accentText,
    Color? cardSurface,
    Color? elevatedSurface,
  }) =>
      SemanticColors(
        primaryText: primaryText ?? this.primaryText,
        secondaryText: secondaryText ?? this.secondaryText,
        mutedText: mutedText ?? this.mutedText,
        accentText: accentText ?? this.accentText,
        cardSurface: cardSurface ?? this.cardSurface,
        elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      );

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
    );
  }
}

extension SemanticColorsX on BuildContext {
  SemanticColors get semantic =>
      Theme.of(this).extension<SemanticColors>() ?? SemanticColors.light;
}
