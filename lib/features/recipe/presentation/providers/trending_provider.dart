/// Provider for trending / most-liked recipes from Supabase.
///
/// Architecture decision: AsyncNotifierProvider instead of FutureProvider
/// because we need refresh + pagination without recreating the provider.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/recipe_model.dart';

// ---------------------------------------------------------------------------
// Trending state
// ---------------------------------------------------------------------------

class TrendingState {
  const TrendingState({
    this.recipes = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.page = 1,
  });

  final List<RecipeModel> recipes;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;
  final int page;

  static const int _pageSize = 15;

  TrendingState copyWith({
    List<RecipeModel>? recipes,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMore,
    int? page,
  }) =>
      TrendingState(
        recipes: recipes ?? this.recipes,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        error: error,
        hasMore: hasMore ?? this.hasMore,
        page: page ?? this.page,
      );

  static int get pageSize => _pageSize;
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class TrendingNotifier extends StateNotifier<TrendingState> {
  TrendingNotifier() : super(const TrendingState());

  SupabaseClient get _db => Supabase.instance.client;

  Future<void> load({String? regionCountry}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null, page: 1);

    try {
      final rows = await _query(page: 1, regionCountry: regionCountry);
      state = state.copyWith(
        recipes: rows,
        isLoading: false,
        hasMore: rows.length == TrendingState.pageSize,
        page: 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore({String? regionCountry}) async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.page + 1;
      final rows = await _query(page: nextPage, regionCountry: regionCountry);
      state = state.copyWith(
        recipes: [...state.recipes, ...rows],
        isLoadingMore: false,
        hasMore: rows.length == TrendingState.pageSize,
        page: nextPage,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<List<RecipeModel>> _query({
    required int page,
    String? regionCountry,
  }) async {
    final offset = (page - 1) * TrendingState.pageSize;
    var query = _db
        .from('trending_recipes')
        .select()
        .order('favorite_count', ascending: false)
        .range(offset, offset + TrendingState.pageSize - 1);

    if (regionCountry != null && regionCountry.isNotEmpty) {
      query = _db
          .from('trending_recipes')
          .select()
          .or('region_country.eq.$regionCountry,region_country.is.null')
          .order('favorite_count', ascending: false)
          .range(offset, offset + TrendingState.pageSize - 1);
    }

    final response = await query;
    return (response as List<dynamic>)
        .map((json) => _fromTrendingJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Maps trending_recipes columns (snake_case) to RecipeModel.
  static RecipeModel _fromTrendingJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      ingredients: _parseIngredients(json['ingredients']),
      steps: _parseSteps(json['steps']),
      cookingTimeMinutes: (json['cooking_time_minutes'] as int?) ?? 30,
      difficulty: (json['difficulty'] as String?) ?? 'Medium',
      category: (json['category'] as String?) ?? 'Dinner',
      servings: (json['servings'] as int?) ?? 2,
      caloriesPerServing: json['calories_per_serving'] as int?,
      imageUrl: json['image_url'] as String?,
      tags: _parseStringList(json['tags']),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static List<Ingredient> _parseIngredients(dynamic raw) {
    if (raw is! List) return [];
    return raw.map((e) {
      if (e is String) return Ingredient(name: e);
      if (e is Map) {
        final m = Map<String, dynamic>.from(e);
        return Ingredient(
          name: (m['name'] ?? '').toString(),
          quantity: m['quantity']?.toString(),
        );
      }
      return Ingredient(name: e.toString());
    }).toList();
  }

  static List<CookingStep> _parseSteps(dynamic raw) {
    if (raw is! List) return [];
    return raw.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      if (e is String) return CookingStep(stepNumber: i + 1, instruction: e);
      if (e is Map) {
        final m = Map<String, dynamic>.from(e);
        return CookingStep(
          stepNumber: (m['stepNumber'] as int?) ?? i + 1,
          instruction: (m['instruction'] ?? '').toString(),
        );
      }
      return CookingStep(stepNumber: i + 1, instruction: e.toString());
    }).toList();
  }

  static List<String> _parseStringList(dynamic raw) {
    if (raw is! List) return [];
    return raw.map((e) => e.toString()).toList();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final trendingNotifierProvider =
    StateNotifierProvider<TrendingNotifier, TrendingState>(
  (_) => TrendingNotifier(),
);
