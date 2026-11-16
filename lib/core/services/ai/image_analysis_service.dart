/// Image analysis service for ingredient detection.
///
/// This service uses Gemini's vision capabilities to analyze images
/// and extract ingredient information for recipe generation.
library;

import 'dart:typed_data';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/ai/gemini_service.dart';

/// Result of image analysis with detected ingredients.
class ImageAnalysisResult {
  final List<String> ingredients;
  final String modelUsed;
  final Duration duration;
  final int attemptCount;

  const ImageAnalysisResult({
    required this.ingredients,
    required this.modelUsed,
    required this.duration,
    required this.attemptCount,
  });
}

/// Service for analyzing ingredient images using Gemini Vision.
///
/// Provides production-ready image analysis with:
/// - Automatic retry logic
/// - Timeout handling
/// - Structured ingredient extraction
/// - Error handling and fallback
class ImageAnalysisService {
  final GeminiService _geminiService;

  ImageAnalysisService({
    GeminiService? geminiService,
  }) : _geminiService = geminiService ?? GeminiService();

  /// Analyzes an image to detect ingredients.
  ///
  /// [imageBytes] - The image bytes to analyze
  /// [imageMimeType] - MIME type of the image (e.g., 'image/jpeg')
  /// [config] - Optional Gemini config override
  ///
  /// Returns detected ingredients with metadata.
  ///
  /// Throws [ServerException] on failure after all retries.
  Future<ImageAnalysisResult> analyzeIngredients(
    Uint8List imageBytes,
    String imageMimeType, {
    GeminiConfig? config,
  }) async {
    final prompt = _buildIngredientDetectionPrompt();

    final result = await _geminiService.generateMultiModal(
      prompt,
      imageBytes: imageBytes,
      imageMimeType: imageMimeType,
      config: config,
    );

    final ingredients = _parseIngredients(result.data);

    return ImageAnalysisResult(
      ingredients: ingredients,
      modelUsed: result.modelUsed,
      duration: result.duration,
      attemptCount: result.attemptCount,
    );
  }

  /// Builds the prompt for ingredient detection.
  String _buildIngredientDetectionPrompt() {
    return '''You are an expert chef and food identifier. Analyze this image and identify all visible ingredients.

Return ONLY a valid JSON array of ingredient names. No markdown, no code blocks, no additional text.

Example format:
["tomato", "onion", "garlic", "bell pepper", "olive oil"]

Requirements:
- Identify all visible food items and ingredients
- Use common ingredient names (e.g., "tomato" not "red fruit")
- Include cooking oils, spices, and herbs if visible
- Return exactly what you see - don't add ingredients
- Return ONLY the JSON array
- Maximum 10 ingredients''';
  }

  /// Parses ingredients from Gemini response.
  List<String> _parseIngredients(String response) {
    final trimmed = response.trim();

    // Remove markdown code blocks if present
    String jsonString = trimmed;
    if (jsonString.contains('```json')) {
      final match = RegExp(r'```json\n([\s\S]*?)\n```').firstMatch(jsonString);
      if (match != null && match.group(1) != null) {
        jsonString = match.group(1)!;
      }
    } else if (jsonString.contains('```')) {
      final match = RegExp(r'```\n?([\s\S]*?)\n?```').firstMatch(jsonString);
      if (match != null && match.group(1) != null) {
        jsonString = match.group(1)!;
      }
    }

    try {
      final parsed = jsonString;
      if (parsed.startsWith('[') && parsed.endsWith(']')) {
        // It's already a JSON array string, parse it
        // Simple parsing for array format
        final content = parsed.substring(1, parsed.length - 1);
        if (content.isNotEmpty) {
          final items = content
              .split(',')
              .map((e) => e.trim().replaceAll('"', '').replaceAll("'", ''))
              .toList();
          return items.where((e) => e.isNotEmpty).toList();
        }
        return <String>[];
      }

      // Try to extract from natural language response
      final lines = trimmed.split('\n');
      final ingredients = <String>[];
      for (final line in lines) {
        final cleaned = line
            .trim()
            .replaceAll(RegExp(r'^[-*•]\s*'), '')
            .replaceAll(RegExp(r'^\d+\.\s*'), '');
        if (cleaned.isNotEmpty && cleaned.length > 2) {
          ingredients.add(cleaned);
        }
      }

      return ingredients.take(10).toList();
    } catch (e) {
      throw DataParsingException(
        message: 'Failed to parse ingredients from response: $e',
        code: 'parse_error',
      );
    }
  }
}
