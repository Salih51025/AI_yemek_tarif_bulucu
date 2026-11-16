/// Use case for generating recipes using AI.
/// 
/// This use case encapsulates the business logic for recipe generation
/// via the Supabase Edge Function. It validates input parameters and
/// delegates to the repository for the actual generation operation.
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/base_usecase.dart';
import '../entities/recipe_repository.dart';
import '../models/ingredient_input_model.dart';
import '../models/recipe_generation_response.dart';

/// Use case for generating recipes.
/// 
/// Validates ingredient input parameters and generates recipes
/// via the repository. Returns either the generated recipe response or a failure.
class GenerateRecipesUseCase extends BaseUseCase<RecipeGenerationResponse, IngredientInputModel> {
  final RecipeRepository _repository;

  GenerateRecipesUseCase(this._repository);

  @override
  FutureEitherResult<RecipeGenerationResponse> call(IngredientInputModel input) async {
    // Validate input
    if (!input.isValid()) {
      return const Left(
        DataParsingFailure(
          message: 'Invalid input: at least ingredients or photo URL must be provided',
          code: 'invalid_input',
        ),
      );
    }

    // Validate ingredients if provided
    if (input.ingredients.isNotEmpty) {
      final validIngredients = input.ingredients.where((ing) => ing.trim().isNotEmpty).toList();
      if (validIngredients.isEmpty) {
        return const Left(
          DataParsingFailure(
            message: 'Ingredients list contains only empty strings',
            code: 'empty_ingredients',
          ),
        );
      }
    }

    // Validate photo URL if provided
    if (input.photoUrl != null && input.photoUrl!.isEmpty) {
      return const Left(
        DataParsingFailure(
          message: 'Photo URL cannot be empty if provided',
          code: 'invalid_photo_url',
        ),
      );
    }

    // Delegate to repository
    return await _repository.generateRecipesFromAI(input);
  }
}
