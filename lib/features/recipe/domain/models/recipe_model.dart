/// Recipe domain model representing a generated recipe.
/// 
/// This model represents a recipe in the domain layer and is independent
/// of any data source implementation. It uses freezed for immutability
/// and json_serializable for efficient JSON parsing to optimize token usage.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_model.freezed.dart';
part 'recipe_model.g.dart';

/// Recipe domain model.
/// 
/// Contains recipe information including title, ingredients, instructions,
/// metadata, and user-specific data like favorite status. This model is
/// structured to minimize JSON payload size for efficient API communication.
@freezed
class RecipeModel with _$RecipeModel {
  const factory RecipeModel({
    /// Unique recipe identifier
    required String id,

    /// Recipe title
    required String title,

    /// Brief description of the recipe
    String? description,

    /// List of ingredients with quantities
    required List<Ingredient> ingredients,

    /// Structured cooking steps
    required List<CookingStep> steps,

    /// Cooking time in minutes
    required int cookingTimeMinutes,

    /// Preparation time in minutes
    @Default(0) int prepTimeMinutes,

    /// Difficulty level (easy, medium, hard)
    required String difficulty,

    /// Recipe category (breakfast, lunch, dinner, etc.)
    required String category,

    /// Number of servings
    @Default(1) int servings,

    /// Calories per serving (optional)
    int? caloriesPerServing,

    /// Recipe image URL (optional)
    String? imageUrl,

    /// Tags for filtering and search
    @Default([]) List<String> tags,

    /// User who generated/favorited this recipe
    String? userId,

    /// Whether the recipe is favorited by the current user
    @Default(false) bool isFavorite,

    /// Generation timestamp
    required DateTime createdAt,

    /// Last update timestamp
    DateTime? updatedAt,

    /// Source of the recipe (AI-generated, user-created, etc.)
    @Default('ai') String source,
  }) = _RecipeModel;

  factory RecipeModel.fromJson(Map<String, dynamic> json) =>
      _$RecipeModelFromJson(json);
}

/// Ingredient model with optimized structure for token efficiency.
@freezed
class Ingredient with _$Ingredient {
  const factory Ingredient({
    /// Ingredient name
    required String name,

    /// Quantity with unit (e.g., "2 cups", "1 tbsp")
    String? quantity,

    /// Preparation notes (e.g., "chopped", "sliced")
    String? preparation,
  }) = _Ingredient;

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);
}

/// Cooking step model with structured instructions.
@freezed
class CookingStep with _$CookingStep {
  const factory CookingStep({
    /// Step number (1-indexed)
    required int stepNumber,

    /// Step instruction
    required String instruction,

    /// Estimated time for this step in minutes (optional)
    int? durationMinutes,

    /// Optional tip or note for this step
    String? tip,
  }) = _CookingStep;

  factory CookingStep.fromJson(Map<String, dynamic> json) =>
      _$CookingStepFromJson(json);
}
