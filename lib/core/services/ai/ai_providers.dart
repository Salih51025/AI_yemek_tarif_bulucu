/// Riverpod providers for AI services (singleton layer).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'gemini_service.dart';
import 'recipe_ai_parser.dart';
import 'recipe_generation_service.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

final recipeAiParserProvider = Provider<RecipeAiParser>((ref) {
  return const RecipeAiParser();
});

final recipeGenerationServiceProvider = Provider<RecipeGenerationService>((ref) {
  return RecipeGenerationService(
    geminiService: ref.watch(geminiServiceProvider),
    parser: ref.watch(recipeAiParserProvider),
  );
});
