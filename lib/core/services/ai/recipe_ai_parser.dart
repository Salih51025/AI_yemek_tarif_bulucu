import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../debug/agent_debug_log.dart';
import '../../errors/exceptions.dart';
import '../../../features/recipe/domain/models/recipe_model.dart';

/// Parses Gemini JSON into domain [RecipeModel] list with tolerant mapping.
class RecipeAiParser {
  const RecipeAiParser({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  Future<List<RecipeModel>> parse(String raw) async {
    // Small payloads: parse on main isolate (avoids compute hangs on some devices).
    if (raw.length < 100000) {
      return parseSync(raw);
    }
    try {
      return await compute(_parseIsolate, raw);
    } catch (e) {
      // #region agent log
      AgentDebugLog.log(
        location: 'recipe_ai_parser.dart:parse',
        message: 'compute_fallback_sync',
        hypothesisId: 'H8',
        data: {'error': e.toString()},
      );
      // #endregion
      return parseSync(raw);
    }
  }

  List<RecipeModel> parseSync(String raw) => _parseIsolate(raw);

  static List<RecipeModel> _parseIsolate(String raw) {
  const parser = RecipeAiParser();
  return parser._parseInternal(raw);
  }

  List<RecipeModel> _parseInternal(String raw) {
    final jsonString = _extractJson(raw);
    // #region agent log
    AgentDebugLog.log(
      location: 'recipe_ai_parser.dart:_parseInternal',
      message: 'extracted_json',
      hypothesisId: 'H3',
      data: {
        'rawLength': raw.length,
        'jsonLength': jsonString.length,
        'startsWithBrace': jsonString.startsWith('{'),
      },
    );
    // #endregion

    final dynamic decoded;
    try {
      decoded = json.decode(jsonString);
    } catch (e) {
      // #region agent log
      AgentDebugLog.log(
        location: 'recipe_ai_parser.dart:_parseInternal',
        message: 'json_decode_failed',
        hypothesisId: 'H3',
        data: {'error': e.toString()},
      );
      // #endregion
      throw DataParsingException(
        message: 'Invalid JSON from AI: $e',
        code: 'json_decode_failed',
      );
    }

    final List<dynamic> items = _extractRecipeList(decoded);
    if (items.isEmpty) {
      throw const DataParsingException(
        message: 'No recipes in AI response',
        code: 'no_recipes',
      );
    }

    final recipes = <RecipeModel>[];
    for (var i = 0; i < items.length; i++) {
      try {
        final map = _asMap(items[i]);
        final recipe = _mapToRecipe(map);
        recipes.add(recipe);
      } catch (e) {
        // #region agent log
        AgentDebugLog.log(
          location: 'recipe_ai_parser.dart:_parseInternal',
          message: 'recipe_skip',
          hypothesisId: 'H4',
          data: {'index': i, 'error': e.toString()},
        );
        // #endregion
        if (kDebugMode) {
          debugPrint('RecipeAiParser: skipped recipe $i: $e');
        }
      }
    }

    if (recipes.isEmpty) {
      throw const DataParsingException(
        message: 'All recipes failed to parse',
        code: 'all_recipes_invalid',
      );
    }

    // #region agent log
    AgentDebugLog.log(
      location: 'recipe_ai_parser.dart:_parseInternal',
      message: 'parse_success',
      hypothesisId: 'H3',
      data: {'parsedCount': recipes.length, 'inputCount': items.length},
    );
    // #endregion

    return recipes;
  }

  static String _extractJson(String raw) {
    var s = raw.trim();
    if (s.startsWith('```')) {
      final match = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```', multiLine: true)
          .firstMatch(s);
      if (match != null) {
        s = match.group(1)!.trim();
      }
    }
    final firstBrace = s.indexOf('{');
    final firstBracket = s.indexOf('[');
    if (firstBrace >= 0 &&
        (firstBracket < 0 || firstBrace < firstBracket)) {
      final last = s.lastIndexOf('}');
      if (last > firstBrace) {
        return s.substring(firstBrace, last + 1);
      }
    }
    if (firstBracket >= 0) {
      final last = s.lastIndexOf(']');
      if (last > firstBracket) {
        return s.substring(firstBracket, last + 1);
      }
    }
    return s;
  }

  static List<dynamic> _extractRecipeList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);
      if (map['recipes'] is List) return map['recipes'] as List;
      if (map['recipe'] is Map) return [map['recipe']];
    }
    return const [];
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const FormatException('Expected object');
  }

  RecipeModel _mapToRecipe(Map<String, dynamic> json) {
    final rawTitle = (json['title'] as String?)?.trim();
    // Fallback to 'name' field; if still missing use 'Untitled Recipe' rather than
    // discarding a potentially valid recipe.
    final title = (rawTitle?.isNotEmpty == true
            ? rawTitle
            : (json['name'] as String?)?.trim()) ??
        'Untitled Recipe';

    return RecipeModel(
      id: (json['id'] as String?)?.trim().isNotEmpty == true
          ? json['id'] as String
          : _uuid.v4(),
      title: title,
      description: (json['description'] as String?)?.trim(),
      ingredients: _parseIngredients(json['ingredients']),
      steps: _parseSteps(json['steps']),
      cookingTimeMinutes: _parseMinutes(
        json['cookingTimeMinutes'] ?? json['time'] ?? json['cookTime'],
      ),
      prepTimeMinutes: _parseMinutes(json['prepTimeMinutes'], fallback: 0),
      difficulty: _normalizeDifficulty(json['difficulty']),
      category: _normalizeCategory(json['category']),
      servings: _parseInt(json['servings'], fallback: 2),
      caloriesPerServing: _parseOptionalInt(
        json['caloriesPerServing'] ?? json['calories'],
      ),
      imageUrl: json['imageUrl'] as String?,
      tags: _parseStringList(json['tags']),
      userId: json['userId'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? _parseDate(json['updatedAt']) : null,
      source: json['source'] as String? ?? 'ai',
    );
  }

  List<Ingredient> _parseIngredients(dynamic raw) {
    if (raw == null) return const [];
    if (raw is! List) return const [];
    return raw.map((item) {
      if (item is String) {
        return Ingredient(name: item.trim());
      }
      if (item is Map) {
        final m = Map<String, dynamic>.from(item);
        final name = (m['name'] ?? m['ingredient'] ?? '').toString().trim();
        return Ingredient(
          name: name,
          quantity: m['quantity']?.toString(),
          preparation: m['preparation']?.toString(),
        );
      }
      return Ingredient(name: item.toString());
    }).where((i) => i.name.isNotEmpty).toList();
  }

  List<CookingStep> _parseSteps(dynamic raw) {
    if (raw == null) return const [];
    if (raw is! List) return const [];
    final steps = <CookingStep>[];
    for (var i = 0; i < raw.length; i++) {
      final item = raw[i];
      if (item is String) {
        final text = item.trim();
        if (text.isNotEmpty) {
          steps.add(CookingStep(stepNumber: i + 1, instruction: text));
        }
      } else if (item is Map) {
        final m = Map<String, dynamic>.from(item);
        final instruction =
            (m['instruction'] ?? m['step'] ?? m['text'] ?? '').toString().trim();
        if (instruction.isNotEmpty) {
          steps.add(
            CookingStep(
              stepNumber: _parseInt(m['stepNumber'], fallback: i + 1),
              instruction: instruction,
              durationMinutes: _parseOptionalInt(m['durationMinutes']),
              tip: m['tip']?.toString(),
            ),
          );
        }
      }
    }
    return steps;
  }

  static int _parseMinutes(dynamic value, {int fallback = 30}) {
    if (value == null) return fallback;
    if (value is num) return value.toInt();
    final digits = RegExp(r'\d+').firstMatch(value.toString());
    return digits != null ? int.parse(digits.group(0)!) : fallback;
  }

  static int _parseInt(dynamic value, {required int fallback}) {
    if (value == null) return fallback;
    if (value is num) return value.toInt();
    final digits = RegExp(r'\d+').firstMatch(value.toString());
    return digits != null ? int.parse(digits.group(0)!) : fallback;
  }

  static int? _parseOptionalInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    final digits = RegExp(r'\d+').firstMatch(value.toString());
    return digits != null ? int.parse(digits.group(0)!) : null;
  }

  static String _normalizeDifficulty(dynamic value) {
    final d = (value ?? 'Medium').toString().toLowerCase();
    if (d.contains('easy') || d.contains('kolay')) return 'Easy';
    if (d.contains('hard') || d.contains('zor')) return 'Hard';
    return 'Medium';
  }

  static String _normalizeCategory(dynamic value) {
    final c = (value ?? 'Dinner').toString();
    const allowed = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Dessert'];
    for (final a in allowed) {
      if (c.toLowerCase() == a.toLowerCase()) return a;
    }
    return 'Dinner';
  }

  static List<String> _parseStringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
