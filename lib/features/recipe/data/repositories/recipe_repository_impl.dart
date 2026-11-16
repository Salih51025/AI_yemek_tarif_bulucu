/// Implementation of the recipe repository.
///
/// This repository coordinates recipe operations between
/// the data sources and the domain layer, converting exceptions
/// to failures for consistent error handling across the application.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/repositories/base_repository.dart';
import '../datasources/recipe_remote_data_source.dart';
import '../../domain/entities/recipe_repository.dart';
import '../../domain/models/ingredient_input_model.dart';
import '../../domain/models/recipe_generation_response.dart';
import '../../data/mappers/recipe_supabase_mapper.dart';
import '../../domain/models/recipe_model.dart';

/// Implementation of the recipe repository.
///
/// This class implements the [RecipeRepository] interface and handles
/// all recipe operations by delegating to remote data sources.
/// It converts data layer exceptions to domain layer failures.
class RecipeRepositoryImpl extends BaseRepository implements RecipeRepository {
  final RecipeRemoteDataSource _remoteDataSource;
  final SupabaseClient _supabaseClient;
  final Uuid _uuid;

  RecipeRepositoryImpl({
    required RecipeRemoteDataSource remoteDataSource,
    required SupabaseClient supabaseClient,
  })  : _remoteDataSource = remoteDataSource,
        _supabaseClient = supabaseClient,
        _uuid = const Uuid();

  @override
  Future<bool> get hasNetworkConnection async {
    // In a production app, this would check actual network connectivity
    return true;
  }

  @override
  Future<void> clearCache() async {
    // No local cache for recipes in this implementation
    // All data is stored in Supabase
  }

  @override
  FutureEitherResult<RecipeGenerationResponse> generateRecipesFromAI(
    IngredientInputModel input, {
    File? imageFile,
    Uint8List? imageBytes,
    String? imageMimeType,
  }) async {
    try {
      final response = await _remoteDataSource.generateRecipes(
        input,
        imageFile: imageFile,
        imageBytes: imageBytes,
        imageMimeType: imageMimeType,
      );
      return Right(response);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        code: e.code,
      ));
    } on DataParsingException catch (e) {
      return Left(DataParsingFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  FutureEitherResult<RecipeModel> saveRecipeToFavorites({
    required RecipeModel recipe,
    required String userId,
  }) async {
    try {
      // Generate ID if not provided
      final recipeId = recipe.id.isEmpty ? _uuid.v4() : recipe.id;

      final row = RecipeSupabaseMapper.toRow(
        recipe.copyWith(
          id: recipeId,
          isFavorite: true,
          createdAt: recipe.createdAt.millisecondsSinceEpoch == 0
              ? DateTime.now()
              : recipe.createdAt,
          updatedAt: DateTime.now(),
        ),
        userId: userId,
        isFavorite: true,
      );

      final response = await _supabaseClient
          .from('recipes_history')
          .upsert(row, onConflict: 'id')
          .select()
          .single();

      final savedRecipe = RecipeSupabaseMapper.fromRow(
        Map<String, dynamic>.from(response),
      );
      return Right(savedRecipe);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
      ));
    } on DataParsingException catch (e) {
      return Left(DataParsingFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  FutureEitherResult<void> removeRecipeFromFavorites({
    required String recipeId,
    required String userId,
  }) async {
    try {
      // Delete from Supabase recipes_history table
      await _supabaseClient
          .from('recipes_history')
          .delete()
          .eq('id', recipeId)
          .eq('user_id', userId);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  FutureEitherResult<List<RecipeModel>> getFavoriteRecipes({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    final offset = (page - 1) * limit;
    try {
      // Query Supabase for favorite recipes
      final response = await _supabaseClient
          .from('recipes_history')
          .select()
          .eq('user_id', userId)
          .eq('is_favorite', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Parse response to list of RecipeModel
      final recipes = (response as List<dynamic>)
          .map((json) => RecipeSupabaseMapper.fromRow(
                Map<String, dynamic>.from(json as Map),
              ))
          .toList();

      return Right(recipes);
    } on PostgrestException catch (e) {
      if (e.message.contains('is_favorite')) {
        final fallback = await _supabaseClient
            .from('recipes_history')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);
        final recipes = (fallback as List<dynamic>)
            .map((json) => RecipeSupabaseMapper.fromRow(
                  Map<String, dynamic>.from(json as Map),
                ))
            .toList();
        return Right(recipes);
      }
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
      ));
    } on DataParsingException catch (e) {
      return Left(DataParsingFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  FutureEitherResult<RecipeModel> toggleFavoriteRecipe({
    required String recipeId,
    required String userId,
    required bool isFavorite,
  }) async {
    try {
      // Update the favorite status in Supabase
      final response = await _supabaseClient
          .from('recipes_history')
          .update({
            'is_favorite': isFavorite,
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('id', recipeId)
          .eq('user_id', userId)
          .select()
          .single();

      // Parse the response back to RecipeModel
      final updatedRecipe = RecipeSupabaseMapper.fromRow(
        Map<String, dynamic>.from(response),
      );
      return Right(updatedRecipe);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
      ));
    } on DataParsingException catch (e) {
      return Left(DataParsingFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  FutureEitherResult<RecipeModel> getRecipeById(String recipeId) async {
    try {
      // Query Supabase for the recipe
      final response = await _supabaseClient
          .from('recipes_history')
          .select()
          .eq('id', recipeId)
          .single();

      // Parse response to RecipeModel
      final recipe = RecipeSupabaseMapper.fromRow(
        Map<String, dynamic>.from(response),
      );
      return Right(recipe);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // Not found
        return const Left(ServerFailure(
          message: 'Recipe not found',
          code: 'not_found',
        ));
      }
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
      ));
    } on DataParsingException catch (e) {
      return Left(DataParsingFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  FutureEitherResult<List<RecipeModel>> getRecipeHistory({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final offset = (page - 1) * limit;

      // Query Supabase for recipe history
      final response = await _supabaseClient
          .from('recipes_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Parse response to list of RecipeModel
      final recipes = (response as List<dynamic>)
          .map((json) => RecipeSupabaseMapper.fromRow(
                Map<String, dynamic>.from(json as Map),
              ))
          .toList();

      return Right(recipes);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
      ));
    } on DataParsingException catch (e) {
      return Left(DataParsingFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unexpected error: $e'));
    }
  }
}
