/// Maps [RecipeModel] ↔ Supabase `recipes_history` row (snake_case columns).
library;

import '../../domain/models/recipe_model.dart';

abstract final class RecipeSupabaseMapper {
  /// Row for insert/upsert. Omits [isFavorite] when the column is absent in DB.
  static Map<String, dynamic> toRow(
    RecipeModel recipe, {
    required String userId,
    bool isFavorite = true,
    bool includeIsFavoriteColumn = true,
  }) {
    final row = <String, dynamic>{
      'id': recipe.id,
      'user_id': userId,
      'title': recipe.title,
      'description': recipe.description,
      'ingredients': recipe.ingredients.map((e) => e.toJson()).toList(),
      'steps': recipe.steps.map((e) => e.toJson()).toList(),
      'cooking_time_minutes': recipe.cookingTimeMinutes,
      'prep_time_minutes': recipe.prepTimeMinutes,
      'difficulty': recipe.difficulty,
      'category': recipe.category,
      'servings': recipe.servings,
      'image_url': recipe.imageUrl,
      'tags': recipe.tags,
      'source': recipe.source,
      'created_at': recipe.createdAt.toIso8601String(),
      'updated_at': (recipe.updatedAt ?? DateTime.now()).toIso8601String(),
    };
    if (recipe.caloriesPerServing != null) {
      row['calories_per_serving'] = recipe.caloriesPerServing;
    }
    if (includeIsFavoriteColumn) {
      row['is_favorite'] = isFavorite;
    }
    return row;
  }

  static RecipeModel fromRow(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      ingredients: _parseIngredients(json['ingredients']),
      steps: _parseSteps(json['steps']),
      cookingTimeMinutes: (json['cooking_time_minutes'] as num?)?.toInt() ?? 30,
      prepTimeMinutes: (json['prep_time_minutes'] as num?)?.toInt() ?? 0,
      difficulty: (json['difficulty'] as String?) ?? 'Medium',
      category: (json['category'] as String?) ?? 'Dinner',
      servings: (json['servings'] as num?)?.toInt() ?? 2,
      caloriesPerServing: (json['calories_per_serving'] as num?)?.toInt(),
      imageUrl: json['image_url'] as String?,
      tags: _parseStringList(json['tags']),
      userId: json['user_id'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'] as String),
      source: json['source'] as String? ?? 'ai',
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
          preparation: m['preparation']?.toString(),
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
      if (e is Map) {
        final m = Map<String, dynamic>.from(e);
        return CookingStep(
          stepNumber: (m['stepNumber'] as num?)?.toInt() ?? i + 1,
          instruction: (m['instruction'] ?? '').toString(),
          durationMinutes: (m['durationMinutes'] as num?)?.toInt(),
          tip: m['tip'] as String?,
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
