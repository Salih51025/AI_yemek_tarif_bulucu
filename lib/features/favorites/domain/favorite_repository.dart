/// Domain contract for persisted favorites (Supabase + local cache).
library;

import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../recipe/domain/models/recipe_model.dart';

typedef FavoriteEither<T> = Future<Either<Failure, T>>;

abstract class FavoriteRepository {
  FavoriteEither<List<RecipeModel>> fetchFavorites(String userId);

  FavoriteEither<RecipeModel> saveFavorite({
    required RecipeModel recipe,
    required String userId,
  });

  FavoriteEither<void> removeFavorite({
    required String recipeId,
    required String userId,
  });

  Future<List<RecipeModel>> readLocalCache();

  Future<void> writeLocalCache(List<RecipeModel> recipes);
}
