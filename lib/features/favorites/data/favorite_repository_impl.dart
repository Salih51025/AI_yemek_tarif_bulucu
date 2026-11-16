/// Favorite repository: Supabase remote + SharedPreferences cache.
library;

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/failures.dart';
import '../../recipe/domain/models/recipe_model.dart';
import '../domain/favorite_repository.dart';
import 'favorite_local_cache.dart';
import 'favorite_remote_data_source.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  FavoriteRepositoryImpl({
    required FavoriteRemoteDataSource remote,
    required SharedPreferences prefs,
  })  : _remote = remote,
        _prefs = prefs;

  final FavoriteRemoteDataSource _remote;
  final SharedPreferences _prefs;

  @override
  Future<Either<Failure, List<RecipeModel>>> fetchFavorites(
    String userId,
  ) async {
    try {
      final recipes = await _remote.fetchFavorites(userId);
      await writeLocalCache(recipes);
      return Right(recipes);
    } on PostgrestException catch (e) {
      final cached = await readLocalCache();
      if (cached.isNotEmpty) {
        return Right(cached);
      }
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      final cached = await readLocalCache();
      if (cached.isNotEmpty) return Right(cached);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RecipeModel>> saveFavorite({
    required RecipeModel recipe,
    required String userId,
  }) async {
    try {
      final saved = await _remote.saveFavorite(recipe: recipe, userId: userId);
      final cached = await readLocalCache();
      final next = [
        saved,
        ...cached.where((r) => r.id != saved.id),
      ];
      await writeLocalCache(next);
      return Right(saved);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite({
    required String recipeId,
    required String userId,
  }) async {
    try {
      await _remote.removeFavorite(recipeId: recipeId, userId: userId);
      final cached = await readLocalCache();
      await writeLocalCache(
        cached.where((r) => r.id != recipeId).toList(),
      );
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<List<RecipeModel>> readLocalCache() =>
      FavoriteLocalCache.read(_prefs);

  @override
  Future<void> writeLocalCache(List<RecipeModel> recipes) =>
      FavoriteLocalCache.write(_prefs, recipes);
}
