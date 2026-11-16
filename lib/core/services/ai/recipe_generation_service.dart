/// Recipe generation orchestration: prompts → Gemini → tolerant JSON parse.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../debug/agent_debug_log.dart';
import '../../errors/exceptions.dart';
import '../../performance/cache_manager.dart';
import '../../security/env_config.dart';
import '../../../features/recipe/domain/models/recipe_generation_response.dart';
import 'gemini_prompts.dart';
import 'gemini_service.dart';
import 'recipe_ai_parser.dart';

class RecipeGenerationConfig {
  final int recipeCount;
  final String language;
  final String? regionCountry;
  final String? regionCity;

  const RecipeGenerationConfig({
    this.recipeCount = 3,
    this.language = 'en',
    this.regionCountry,
    this.regionCity,
  });
}

class RecipeGenerationResult {
  final RecipeGenerationResponse response;
  final String modelUsed;
  final Duration duration;
  final int attemptCount;

  const RecipeGenerationResult({
    required this.response,
    required this.modelUsed,
    required this.duration,
    required this.attemptCount,
  });
}

class RecipeGenerationService {
  RecipeGenerationService({
    GeminiService? geminiService,
    RecipeAiParser? parser,
    CacheManager? cache,
  })  : _gemini = geminiService ?? GeminiService(),
        _parser = parser ?? const RecipeAiParser(),
        // 6-hour TTL: Gemini recipes for the same ingredients are stable enough.
        // This eliminates redundant API calls for repeated ingredient sets.
        _cache = cache ?? CacheManager(config: const CacheConfig(
          maxMemoryEntries: 50,
          defaultTTL: Duration(hours: 6),
          enableDiskCache: true,
        ));

  final GeminiService _gemini;
  final RecipeAiParser _parser;
  final CacheManager _cache;

  /// Canonical cache key: sorted, lowercase, SHA-256 hash of ingredient list.
  /// Sorting ensures "egg,tomato" == "tomato,egg" hits the same cache entry.
  static String _ingredientCacheKey(List<String> ingredients, String language) {
    final sorted = [...ingredients.map((e) => e.toLowerCase().trim())]..sort();
    final raw = '${sorted.join(',')}|$language';
    return 'recipes_${sha256.convert(utf8.encode(raw)).toString().substring(0, 16)}';
  }

  Future<RecipeGenerationResult> generateFromIngredients(
    List<String> ingredients, {
    RecipeGenerationConfig? config,
    GeminiConfig? geminiConfig,
    bool forceRefresh = false,
  }) async {
    _assertApiKey();
    final effective = config ?? const RecipeGenerationConfig();
    final cacheKey = _ingredientCacheKey(ingredients, effective.language);
    // #region agent log
    AgentDebugLog.log(
      location: 'recipe_generation_service.dart:generateFromIngredients',
      message: 'effective_config',
      hypothesisId: 'H-LOC3',
      runId: 'pre-fix',
      data: {
        'effectiveLanguage': effective.language,
        'hasConfig': config != null,
        'cacheKey': cacheKey,
      },
    );
    // #endregion

    // Return cached result immediately — no Gemini call, ~0ms latency.
    if (!forceRefresh) {
      final cached = _cache.get<RecipeGenerationResult>(cacheKey);
      if (cached != null) {
        AgentDebugLog.log(
          location: 'recipe_generation_service.dart:generateFromIngredients',
          message: 'cache_hit',
          hypothesisId: 'PERF',
          data: {'key': cacheKey},
        );
        return cached;
      }
    }

    final prompt = GeminiPrompts.recipeFromIngredients(
      ingredients: ingredients,
      count: effective.recipeCount,
      language: effective.language,
      regionCountry: effective.regionCountry,
      regionCity: effective.regionCity,
    );
    // #region agent log
    AgentDebugLog.log(
      location: 'recipe_generation_service.dart:generateFromIngredients',
      message: 'prompt_language_line',
      hypothesisId: 'H-LOC4',
      runId: 'pre-fix',
      data: {
        'effectiveLanguage': effective.language,
        'hasLanguageLine': prompt.contains('Language:'),
        'promptHead': prompt.split('\n').take(3).join(' | '),
      },
    );
    // #endregion

    final result = await _gemini.generateText(
      prompt,
      systemInstruction: GeminiPrompts.recipeSystemInstruction,
      config: geminiConfig,
    );

    final generationResult = await _toResult(result, effective);
    // Cache only successful, non-empty results.
    if (generationResult.response.recipes.isNotEmpty) {
      await _cache.set(cacheKey, generationResult);
    }
    return generationResult;
  }

  Future<RecipeGenerationResult> generateFromImage(
    Uint8List imageBytes,
    String imageMimeType, {
    List<String> extraIngredients = const [],
    RecipeGenerationConfig? config,
    GeminiConfig? geminiConfig,
  }) async {
    _assertApiKey();
    final effective = config ?? const RecipeGenerationConfig();
    // #region agent log
    AgentDebugLog.log(
      location: 'recipe_generation_service.dart:generateFromImage',
      message: 'effective_config',
      hypothesisId: 'H-LOC5',
      runId: 'pre-fix',
      data: {
        'effectiveLanguage': effective.language,
        'hasConfig': config != null,
        'extraIngredientCount': extraIngredients.length,
      },
    );
    // #endregion
    final prompt = GeminiPrompts.recipeFromImage(
      count: effective.recipeCount,
      language: effective.language,
      extraIngredients: extraIngredients,
    );

    final result = await _gemini.generateMultiModal(
      prompt,
      imageBytes: imageBytes,
      imageMimeType: imageMimeType,
      systemInstruction: GeminiPrompts.recipeSystemInstruction,
      config: geminiConfig,
    );

    return _toResult(result, effective);
  }

  Future<RecipeGenerationResult> _toResult(
    GeminiResult<String> result,
    RecipeGenerationConfig config,
  ) async {
    try {
      final recipes = await _parser.parse(result.data);
      final response = RecipeGenerationResponse(
        recipes: recipes,
        success: true,
        error: null,
        tokensUsed: result.tokensUsed,
        generationTimeMs: result.duration.inMilliseconds,
        modelVersion: result.modelUsed,
      );
      return RecipeGenerationResult(
        response: response,
        modelUsed: result.modelUsed,
        duration: result.duration,
        attemptCount: result.attemptCount,
      );
    } on DataParsingException catch (e) {
      // #region agent log
      AgentDebugLog.log(
        location: 'recipe_generation_service.dart:_toResult',
        message: 'parse_failed',
        hypothesisId: 'H3',
        data: {'error': e.message, 'code': e.code ?? ''},
      );
      // #endregion
      rethrow;
    }
  }

  void _assertApiKey() {
    final key = EnvConfig.geminiApiKey;
    if (key.isEmpty ||
        key == 'YOUR_GEMINI_API_KEY_HERE' ||
        key.startsWith('YOUR_')) {
      throw const ServerException(
        message: 'GEMINI_API_KEY not configured in .env',
        code: 'missing_api_key',
      );
    }
  }
}
