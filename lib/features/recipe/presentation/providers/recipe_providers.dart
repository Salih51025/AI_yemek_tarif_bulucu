/// Riverpod providers for recipe feature.
///
/// This file provides all the dependency injection for the recipe
/// feature including data sources, repositories, and use cases.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/security/env_config.dart';
import '../../../../core/services/ai/ai_providers.dart';
import '../../../../core/localization/presentation/locale_provider.dart';
import '../../data/datasources/recipe_remote_data_source.dart';
import '../../data/repositories/recipe_repository_impl.dart';
import '../../domain/entities/recipe_repository.dart';
import '../../domain/usecases/generate_recipes_usecase.dart';
import '../../domain/usecases/get_favorites_usecase.dart';
import '../../domain/usecases/toggle_favorite_recipe_usecase.dart';

/// Provider for DioClient.
///
/// Creates and provides a configured DioClient instance.
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

/// Provider for RecipeRemoteDataSource.
///
/// Creates and provides the RecipeRemoteDataSource with DioClient and Supabase URL.
final recipeRemoteDataSourceProvider = Provider<RecipeRemoteDataSource>((ref) {
  final dioClient = ref.read(dioClientProvider);
  final generationService = ref.watch(recipeGenerationServiceProvider);
  final locale = ref.watch(localeProvider);
  return RecipeRemoteDataSource(
    dioClient: dioClient,
    supabaseUrl: EnvConfig.supabaseUrl,
    recipeGenerationService: generationService,
    locale: locale,
  );
});

/// Provider for RecipeRepository.
///
/// Creates and provides the RecipeRepository implementation with all dependencies.
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final remoteDataSource = ref.read(recipeRemoteDataSourceProvider);
  final supabaseClient = ref.read(supabaseClientProvider);

  return RecipeRepositoryImpl(
    remoteDataSource: remoteDataSource,
    supabaseClient: supabaseClient,
  );
});

/// Provider for GenerateRecipesUseCase.
///
/// Creates and provides the GenerateRecipesUseCase with RecipeRepository.
final generateRecipesUseCaseProvider = Provider<GenerateRecipesUseCase>((ref) {
  final repository = ref.read(recipeRepositoryProvider);
  return GenerateRecipesUseCase(repository);
});

/// Provider for ToggleFavoriteRecipeUseCase.
///
/// Creates and provides the ToggleFavoriteRecipeUseCase with RecipeRepository.
final toggleFavoriteRecipeUseCaseProvider =
    Provider<ToggleFavoriteRecipeUseCase>((ref) {
  final repository = ref.read(recipeRepositoryProvider);
  return ToggleFavoriteRecipeUseCase(repository);
});

/// Provider for GetFavoritesUseCase.
///
/// Creates and provides the GetFavoritesUseCase with RecipeRepository.
final getFavoritesUseCaseProvider = Provider<GetFavoritesUseCase>((ref) {
  final repository = ref.read(recipeRepositoryProvider);
  return GetFavoritesUseCase(repository);
});

