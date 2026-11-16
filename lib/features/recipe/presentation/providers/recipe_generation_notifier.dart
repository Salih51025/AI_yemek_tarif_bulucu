/// AsyncNotifier for recipe generation — single source of truth for UI state.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/debug/agent_debug_log.dart';
import '../../../../core/localization/presentation/locale_provider.dart';
import '../../../../core/security/env_config.dart';
import '../../domain/models/ingredient_input_model.dart';
import '../../domain/models/recipe_generation_response.dart';
import '../../domain/models/recipe_model.dart';
import '../providers/recipe_providers.dart';

/// UI state for the recipe generation flow.
sealed class RecipeGenerationUiState {
  const RecipeGenerationUiState();
}

class RecipeGenerationIdle extends RecipeGenerationUiState {
  const RecipeGenerationIdle();
}

class RecipeGenerationLoading extends RecipeGenerationUiState {
  const RecipeGenerationLoading();
}

class RecipeGenerationSuccess extends RecipeGenerationUiState {
  const RecipeGenerationSuccess(this.response);

  final RecipeGenerationResponse response;

  List<RecipeModel> get recipes => response.recipes;
}

class RecipeGenerationFailure extends RecipeGenerationUiState {
  const RecipeGenerationFailure(this.message);

  final String message;
}

class RecipeGenerationNotifier extends StateNotifier<RecipeGenerationUiState> {
  RecipeGenerationNotifier(this._ref) : super(const RecipeGenerationIdle());

  final Ref _ref;

  bool get isLoading => state is RecipeGenerationLoading;

  Future<RecipeGenerationResponse?> generate({
    required List<String> ingredients,
    File? imageFile,
    Uint8List? imageBytes,
    String? imageMimeType,
  }) async {
    if (isLoading) return null;

    // #region agent log
    AgentDebugLog.log(
      location: 'recipe_generation_notifier.dart:generate',
      message: 'generate_start',
      hypothesisId: 'H-LOC1',
      runId: 'post-fix',
      data: {
        'selectedLocale': _ref.read(localeProvider)?.toLanguageTag() ?? 'null',
        'apiKeyLen': EnvConfig.geminiApiKey.length,
        'model': EnvConfig.geminiModel,
        'hasImage': imageBytes != null,
        'ingredientCount': ingredients.length,
      },
    );
    // #endregion

    state = const RecipeGenerationLoading();

    final input = IngredientInputModel(ingredients: ingredients);
    final repository = _ref.read(recipeRepositoryProvider);

    try {
      final result = await repository.generateRecipesFromAI(
        input,
        imageFile: imageFile,
        imageBytes: imageBytes,
        imageMimeType: imageMimeType,
      );

      return result.fold(
      (failure) {
        // #region agent log
        AgentDebugLog.log(
          location: 'recipe_generation_notifier.dart:generate',
          message: 'generation_failed',
          hypothesisId: 'H1',
          runId: 'post-fix',
          data: {
            'code': failure.code ?? '',
            'message': failure.message.split('\n').first,
            'hasImage': imageFile != null || imageBytes != null,
            'ingredientCount': ingredients.length,
          },
        );
        // #endregion
        state = RecipeGenerationFailure(failure.message);
        return null;
      },
      (response) {
        // #region agent log
        AgentDebugLog.log(
          location: 'recipe_generation_notifier.dart:generate',
          message: 'generation_success',
          hypothesisId: 'H3',
          runId: 'post-fix',
          data: {'recipeCount': response.recipes.length},
        );
        // #endregion
        state = RecipeGenerationSuccess(response);
        return response;
      },
    );
    } catch (e, st) {
      // #region agent log
      AgentDebugLog.log(
        location: 'recipe_generation_notifier.dart:generate',
        message: 'generation_uncaught',
        hypothesisId: 'H10',
        runId: 'post-fix',
        data: {
          'error': e.toString().split('\n').first,
          'stack': st.toString().split('\n').take(3).join(' | '),
        },
      );
      // #endregion
      state = RecipeGenerationFailure(e.toString().split('\n').first);
      return null;
    }
  }

  void reset() => state = const RecipeGenerationIdle();
}

final recipeGenerationNotifierProvider =
    StateNotifierProvider<RecipeGenerationNotifier, RecipeGenerationUiState>(
  (ref) => RecipeGenerationNotifier(ref),
);

/// Back-compat: list of recipes derived from generation state.
final generatedRecipesListProvider = Provider<List<RecipeModel>>((ref) {
  final state = ref.watch(recipeGenerationNotifierProvider);
  if (state is RecipeGenerationSuccess) {
    return state.recipes;
  }
  return const [];
});
