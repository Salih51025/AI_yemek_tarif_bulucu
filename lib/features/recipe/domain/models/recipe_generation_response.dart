/// Recipe generation response model from Edge Function.
///
/// This model represents the structured response from the Supabase Edge Function
/// after AI recipe generation. It's designed to minimize token usage with
/// compact field names and efficient JSON structure.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'recipe_model.dart';

part 'recipe_generation_response.freezed.dart';
part 'recipe_generation_response.g.dart';

/// Recipe generation response from Edge Function.
///
/// Contains the generated recipes along with metadata about the generation
/// process. Uses compact field names to optimize token efficiency.
@freezed
class RecipeGenerationResponse with _$RecipeGenerationResponse {
  const factory RecipeGenerationResponse({
    /// Generated recipe data (array of recipes)
    required List<RecipeModel> recipes,

    /// Generation success status
    @Default(true) bool success,

    /// Error message if generation failed
    String? error,

    /// Tokens used for generation (for cost tracking)
    int? tokensUsed,

    /// Generation time in milliseconds
    int? generationTimeMs,

    /// Model version used for generation
    String? modelVersion,
  }) = _RecipeGenerationResponse;

  factory RecipeGenerationResponse.fromJson(Map<String, dynamic> json) =>
      _$RecipeGenerationResponseFromJson(json);
}
