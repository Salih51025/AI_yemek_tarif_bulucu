/// Use case for toggling recipe favorite status.
/// 
/// This use case encapsulates the business logic for toggling
/// the favorite status of a recipe. It validates input parameters
/// and delegates to the repository for the actual operation.
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/base_usecase.dart';
import '../entities/recipe_repository.dart';
import '../models/recipe_model.dart';

/// Parameters for the toggle favorite use case.
class ToggleFavoriteParams {
  final String recipeId;
  final String userId;
  final bool isFavorite;

  ToggleFavoriteParams({
    required this.recipeId,
    required this.userId,
    required this.isFavorite,
  });
}

/// Use case for toggling recipe favorite status.
/// 
/// Validates recipe ID, user ID, and favorite status parameters,
/// then toggles the favorite status via the repository.
/// Returns either the updated recipe or a failure.
class ToggleFavoriteRecipeUseCase extends BaseUseCase<RecipeModel, ToggleFavoriteParams> {
  final RecipeRepository _repository;

  ToggleFavoriteRecipeUseCase(this._repository);

  @override
  FutureEitherResult<RecipeModel> call(ToggleFavoriteParams params) async {
    // Validate recipe ID
    if (params.recipeId.isEmpty) {
      return const Left(
        DataParsingFailure(
          message: 'Recipe ID is required',
          code: 'recipe_id_required',
        ),
      );
    }

    // Validate user ID
    if (params.userId.isEmpty) {
      return const Left(
        DataParsingFailure(
          message: 'User ID is required',
          code: 'user_id_required',
        ),
      );
    }

    // Delegate to repository
    return await _repository.toggleFavoriteRecipe(
      recipeId: params.recipeId,
      userId: params.userId,
      isFavorite: params.isFavorite,
    );
  }
}
