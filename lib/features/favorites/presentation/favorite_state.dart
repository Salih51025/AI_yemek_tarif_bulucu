/// Immutable favorites state with O(1) id lookup.
library;

import '../../recipe/domain/models/recipe_model.dart';

class FavoriteState {
  const FavoriteState({
    this.byId = const {},
    this.togglingIds = const {},
    this.isLoading = false,
    this.error,
    this.hydrated = false,
  });

  /// recipeId → recipe (favorite set).
  final Map<String, RecipeModel> byId;

  /// In-flight toggles (prevents double-tap races).
  final Set<String> togglingIds;

  final bool isLoading;
  final String? error;

  /// True after first load/cache hydrate attempt.
  final bool hydrated;

  List<RecipeModel> get recipes => byId.values.toList();

  bool isFavorite(String recipeId) => byId.containsKey(recipeId);

  bool isToggling(String recipeId) => togglingIds.contains(recipeId);

  FavoriteState copyWith({
    Map<String, RecipeModel>? byId,
    Set<String>? togglingIds,
    bool? isLoading,
    String? error,
    bool? hydrated,
    bool clearError = false,
  }) =>
      FavoriteState(
        byId: byId ?? this.byId,
        togglingIds: togglingIds ?? this.togglingIds,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        hydrated: hydrated ?? this.hydrated,
      );
}
