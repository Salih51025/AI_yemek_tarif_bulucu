/// Riverpod notifier: single source of truth for favorites.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/debug/session_debug_log.dart';
import '../../recipe/domain/models/recipe_model.dart';
import '../application/favorite_service.dart';
import 'favorite_state.dart';

class FavoriteNotifier extends StateNotifier<FavoriteState> {
  FavoriteNotifier(this._service) : super(const FavoriteState());

  final FavoriteService _service;

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  /// Hydrate from cache immediately, then sync remote.
  Future<void> load() async {
    final uid = _userId;
    // #region agent log
    SessionDebugLog.log(
      location: 'favorite_notifier.dart:load',
      message: 'load() start',
      hypothesisId: 'H2',
      data: {'uidPresent': uid != null, 'byIdSize': state.byId.length},
      runId: 'post-fix',
    );
    // #endregion
    if (uid == null) return;
    if (state.isLoading) return;

    final cached = await _service.loadCachedFavorites();
    if (cached.isNotEmpty) {
      state = state.copyWith(
        byId: {for (final r in cached) r.id: r},
        hydrated: true,
      );
    }

    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _service.loadFavorites(uid);
    result.fold(
      (failure) {
        // #region agent log
        SessionDebugLog.log(
          location: 'favorite_notifier.dart:load',
          message: 'load() remote failed',
          hypothesisId: 'H2',
          data: {'error': failure.message, 'cachedSize': state.byId.length},
          runId: 'post-fix',
        );
        // #endregion
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          hydrated: true,
        );
      },
      (recipes) {
        // #region agent log
        SessionDebugLog.log(
          location: 'favorite_notifier.dart:load',
          message: 'load() remote success',
          hypothesisId: 'H2',
          data: {'count': recipes.length},
          runId: 'post-fix',
        );
        // #endregion
        state = state.copyWith(
          isLoading: false,
          byId: {for (final r in recipes) r.id: r},
          hydrated: true,
          clearError: true,
        );
      },
    );
  }

  Future<void> toggle(RecipeModel recipe) async {
    final uid = _userId;
    if (uid == null) return;
    if (state.isToggling(recipe.id)) return;

    final wasFavorite = state.isFavorite(recipe.id);
    // #region agent log
    SessionDebugLog.log(
      location: 'favorite_notifier.dart:toggle',
      message: 'toggle() start',
      hypothesisId: 'H3',
      data: {
        'recipeId': recipe.id,
        'wasFavorite': wasFavorite,
        'byIdSize': state.byId.length,
      },
      runId: 'post-fix',
    );
    // #endregion

    final toggling = {...state.togglingIds, recipe.id};
    final optimisticById = Map<String, RecipeModel>.from(state.byId);
    RecipeModel snapshot;
    if (wasFavorite) {
      snapshot = optimisticById[recipe.id] ?? recipe;
      optimisticById.remove(recipe.id);
    } else {
      snapshot = recipe.copyWith(isFavorite: true);
      optimisticById[recipe.id] = snapshot;
    }

    state = state.copyWith(byId: optimisticById, togglingIds: toggling);

    if (wasFavorite) {
      final result = await _service.removeFavorite(
        recipeId: recipe.id,
        userId: uid,
      );
      result.fold(
        (failure) {
          // #region agent log
          SessionDebugLog.log(
            location: 'favorite_notifier.dart:toggle',
            message: 'remove failed — rollback',
            hypothesisId: 'H3',
            data: {'recipeId': recipe.id, 'error': failure.message},
            runId: 'post-fix',
          );
          // #endregion
          final rollback = Map<String, RecipeModel>.from(state.byId);
          rollback[recipe.id] = snapshot;
          state = state.copyWith(
            byId: rollback,
            togglingIds: {...state.togglingIds}..remove(recipe.id),
            error: failure.message,
          );
        },
        (_) {
          state = state.copyWith(
            togglingIds: {...state.togglingIds}..remove(recipe.id),
            clearError: true,
          );
        },
      );
    } else {
      final result = await _service.addFavorite(recipe: recipe, userId: uid);
      result.fold(
        (failure) {
          // #region agent log
          SessionDebugLog.log(
            location: 'favorite_notifier.dart:toggle',
            message: 'save failed — rollback',
            hypothesisId: 'H3',
            data: {'recipeId': recipe.id, 'error': failure.message},
            runId: 'post-fix',
          );
          // #endregion
          final rollback = Map<String, RecipeModel>.from(state.byId);
          rollback.remove(recipe.id);
          state = state.copyWith(
            byId: rollback,
            togglingIds: {...state.togglingIds}..remove(recipe.id),
            error: failure.message,
          );
        },
        (saved) {
          // #region agent log
          SessionDebugLog.log(
            location: 'favorite_notifier.dart:toggle',
            message: 'save success',
            hypothesisId: 'H3',
            data: {'recipeId': recipe.id, 'savedId': saved.id},
            runId: 'post-fix',
          );
          // #endregion
          final next = Map<String, RecipeModel>.from(state.byId);
          if (saved.id != recipe.id) {
            next.remove(recipe.id);
          }
          next[saved.id] = saved;
          state = state.copyWith(
            byId: next,
            togglingIds: {...state.togglingIds}..remove(recipe.id),
            clearError: true,
          );
        },
      );
    }
  }

  void clearError() => state = state.copyWith(clearError: true);

  void reset() => state = const FavoriteState();
}
