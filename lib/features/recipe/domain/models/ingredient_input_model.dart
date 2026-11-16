/// Ingredient input model for recipe generation requests.
///
/// This model represents user input for generating recipes, including
/// manually entered ingredients and uploaded photos. It's designed to
/// minimize payload size for efficient API communication with the
/// Supabase Edge Function.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ingredient_input_model.freezed.dart';
part 'ingredient_input_model.g.dart';

/// Ingredient input model for recipe generation.
///
/// This model is used when requesting recipe generation from the AI.
/// It supports both text-based ingredient input and photo-based input.
@freezed
class IngredientInputModel with _$IngredientInputModel {
  const IngredientInputModel._();

  const factory IngredientInputModel({
    /// List of ingredient names entered by user
    @Default([]) List<String> ingredients,

    /// Firebase Storage URL of ingredient photo (optional)
    String? photoUrl,

    /// Additional preferences or constraints
    String? preferences,

    /// Desired cuisine type (optional)
    String? cuisine,

    /// Dietary restrictions (optional)
    @Default([]) List<String> dietaryRestrictions,

    /// Maximum cooking time in minutes (optional)
    int? maxCookingTime,

    /// Desired difficulty level (optional)
    String? difficulty,
  }) = _IngredientInputModel;

  factory IngredientInputModel.fromJson(Map<String, dynamic> json) =>
      _$IngredientInputModelFromJson(json);

  /// Validates the input model.
  ///
  /// Returns true if the input is valid for recipe generation.
  /// At least one of [ingredients] or [photoUrl] must be provided.
  bool isValid() {
    return (ingredients.isNotEmpty || photoUrl != null);
  }

  /// Converts to a compact JSON structure for API requests.
  ///
  /// This method optimizes the JSON structure to minimize token usage
  /// when sending to the Supabase Edge Function.
  Map<String, dynamic> toCompactJson() {
    final json = toJson();
    // Remove null values to reduce payload size
    json.removeWhere((key, value) => value == null);
    return json;
  }
}
