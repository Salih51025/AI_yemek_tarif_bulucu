/// Repository interface for recipe operations.
///
/// This abstract class defines the contract for recipe-related
/// operations that must be implemented by the data layer.
/// It follows Clean Architecture principles by defining the
/// interface in the domain layer.
library;

import 'dart:io';
import 'dart:typed_data';

import '../../../../core/errors/failures.dart';
import '../../../../core/repositories/base_repository.dart';
import '../models/ingredient_input_model.dart';
import '../models/recipe_generation_response.dart';
import '../models/recipe_model.dart';

/// Repository interface for recipe operations.
///
/// Defines the contract for all recipe-related operations
/// including AI generation, favorites management, and persistence.
/// All methods return [EitherResult] for consistent error handling.
abstract class RecipeRepository extends BaseRepository {
  /// Generates recipes using AI via Supabase Edge Function.
  ///
  /// [input] - Ingredient input model containing ingredients or photo URL
  /// [imageFile] - Optional local image file for vision-based recipe generation
  /// [imageBytes] - Optional image bytes for vision-based recipe generation
  /// [imageMimeType] - MIME type of the image (e.g., 'image/jpeg', 'image/png')
  ///
  /// Returns [EitherResult] containing either the generated recipe response or a [Failure].
  FutureEitherResult<RecipeGenerationResponse> generateRecipesFromAI(
    IngredientInputModel input, {
    File? imageFile,
    Uint8List? imageBytes,
    String? imageMimeType,
  });

  /// Saves a recipe to the user's favorites in Supabase.
  ///
  /// [recipe] - The recipe model to save
  /// [userId] - The user ID who is saving the recipe
  ///
  /// Returns [EitherResult] containing either the saved recipe or a [Failure].
  FutureEitherResult<RecipeModel> saveRecipeToFavorites({
    required RecipeModel recipe,
    required String userId,
  });

  /// Removes a recipe from the user's favorites.
  ///
  /// [recipeId] - The ID of the recipe to remove
  /// [userId] - The user ID who owns the recipe
  ///
  /// Returns [EitherResult] containing either Unit (success) or a [Failure].
  FutureEitherResult<void> removeRecipeFromFavorites({
    required String recipeId,
    required String userId,
  });

  /// Gets all favorite recipes for a user.
  ///
  /// [userId] - The user ID to fetch favorites for
  /// [page] - Page number for pagination (default: 1)
  /// [limit] - Number of items per page (default: 20)
  ///
  /// Returns [EitherResult] containing either a list of recipes or a [Failure].
  FutureEitherResult<List<RecipeModel>> getFavoriteRecipes({
    required String userId,
    int page = 1,
    int limit = 20,
  });

  /// Toggles the favorite status of a recipe.
  ///
  /// [recipeId] - The ID of the recipe to toggle
  /// [userId] - The user ID who owns the recipe
  /// [isFavorite] - The new favorite status
  ///
  /// Returns [EitherResult] containing either the updated recipe or a [Failure].
  FutureEitherResult<RecipeModel> toggleFavoriteRecipe({
    required String recipeId,
    required String userId,
    required bool isFavorite,
  });

  /// Gets a recipe by its ID.
  ///
  /// [recipeId] - The ID of the recipe to fetch
  ///
  /// Returns [EitherResult] containing either the recipe or a [Failure].
  FutureEitherResult<RecipeModel> getRecipeById(String recipeId);

  /// Gets the recipe generation history for a user.
  ///
  /// [userId] - The user ID to fetch history for
  /// [page] - Page number for pagination (default: 1)
  /// [limit] - Number of items per page (default: 20)
  ///
  /// Returns [EitherResult] containing either a list of recipes or a [Failure].
  FutureEitherResult<List<RecipeModel>> getRecipeHistory({
    required String userId,
    int page = 1,
    int limit = 20,
  });
}
