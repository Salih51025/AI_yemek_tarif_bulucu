/// Device cache for favorites (offline / failed remote load).
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../recipe/domain/models/recipe_model.dart';

abstract final class FavoriteLocalCache {
  static const _key = 'favorite_recipes_cache_v1';

  static Future<List<RecipeModel>> read(SharedPreferences prefs) async {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> write(
    SharedPreferences prefs,
    List<RecipeModel> recipes,
  ) async {
    final encoded = jsonEncode(recipes.map((r) => r.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  static Future<void> clear(SharedPreferences prefs) async {
    await prefs.remove(_key);
  }
}
