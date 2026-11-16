/// Business logic for favorite toggles (optimistic + rollback orchestration).
library;

import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../recipe/domain/models/recipe_model.dart';
import '../domain/favorite_repository.dart';

class FavoriteService {
  FavoriteService(this._repository);

  final FavoriteRepository _repository;

  Future<Either<Failure, List<RecipeModel>>> loadFavorites(String userId) =>
      _repository.fetchFavorites(userId);

  Future<Either<Failure, RecipeModel>> addFavorite({
    required RecipeModel recipe,
    required String userId,
  }) =>
      _repository.saveFavorite(recipe: recipe, userId: userId);

  Future<Either<Failure, void>> removeFavorite({
    required String recipeId,
    required String userId,
  }) =>
      _repository.removeFavorite(recipeId: recipeId, userId: userId);

  Future<List<RecipeModel>> loadCachedFavorites() =>
      _repository.readLocalCache();
}
