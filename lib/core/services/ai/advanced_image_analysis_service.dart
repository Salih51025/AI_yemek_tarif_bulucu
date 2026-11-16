/// Advanced Image Analysis Service
///
/// Enterprise-grade image analysis with confidence scoring, multiple ingredient detection,
/// blurry image handling, low-light detection, and ingredient grouping.
library;

import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../../errors/exceptions.dart';
import 'gemini_service.dart';

// ============================================================================
// IMAGE ANALYSIS RESULT
// ============================================================================

class DetectedIngredient {
  final String name;
  final double confidence;
  final String? category;
  final Map<String, dynamic>? metadata;

  DetectedIngredient({
    required this.name,
    required this.confidence,
    this.category,
    this.metadata,
  });

  factory DetectedIngredient.fromJson(Map<String, dynamic> json) {
    return DetectedIngredient(
      name: json['name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      category: json['category'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'confidence': confidence,
      'category': category,
      'metadata': metadata,
    };
  }
}

class ImageQualityMetrics {
  final bool isBlurry;
  final double blurScore;
  final bool isLowLight;
  final double brightnessScore;
  final bool hasGoodContrast;
  final double contrastScore;
  final int estimatedIngredientCount;
  final String qualityAssessment; // 'excellent', 'good', 'fair', 'poor'

  ImageQualityMetrics({
    required this.isBlurry,
    required this.blurScore,
    required this.isLowLight,
    required this.brightnessScore,
    required this.hasGoodContrast,
    required this.contrastScore,
    required this.estimatedIngredientCount,
    required this.qualityAssessment,
  });
}

class ImageAnalysisResult {
  final List<DetectedIngredient> ingredients;
  final ImageQualityMetrics qualityMetrics;
  final String? errorMessage;
  final bool success;
  final int processingTimeMs;

  ImageAnalysisResult({
    required this.ingredients,
    required this.qualityMetrics,
    this.errorMessage,
    required this.success,
    required this.processingTimeMs,
  });
}

// ============================================================================
// ADVANCED IMAGE ANALYSIS SERVICE
// ============================================================================

class AdvancedImageAnalysisService {
  final GeminiService _geminiService;

  AdvancedImageAnalysisService({
    GeminiService? geminiService,
  }) : _geminiService = geminiService ?? GeminiService();

  /// Analyze image for ingredients with confidence scoring
  Future<ImageAnalysisResult> analyzeIngredients(
    Uint8List imageBytes,
    String mimeType, {
    bool enableQualityCheck = true,
    bool enableGrouping = true,
    double minConfidence = 0.5,
  }) async {
    final startTime = DateTime.now();

    // Check image quality if enabled
    ImageQualityMetrics? qualityMetrics;
    try {
      if (enableQualityCheck) {
        qualityMetrics = await _analyzeImageQuality(imageBytes);

        // Warn if image quality is poor
        if (qualityMetrics.qualityAssessment == 'poor') {
          return ImageAnalysisResult(
            ingredients: [],
            qualityMetrics: qualityMetrics,
            errorMessage:
                'Image quality is too poor for reliable analysis. Please use a clearer, brighter image.',
            success: false,
            processingTimeMs:
                DateTime.now().difference(startTime).inMilliseconds,
          );
        }
      } else {
        qualityMetrics = ImageQualityMetrics(
          isBlurry: false,
          blurScore: 1.0,
          isLowLight: false,
          brightnessScore: 1.0,
          hasGoodContrast: true,
          contrastScore: 1.0,
          estimatedIngredientCount: 0,
          qualityAssessment: 'good',
        );
      }

      // Build advanced prompt for ingredient detection
      final prompt = _buildIngredientDetectionPrompt(
        minConfidence,
        enableGrouping,
      );

      // Call Gemini for analysis
      final result = await _geminiService.generateMultiModal(
        prompt,
        imageBytes: imageBytes,
        imageMimeType: mimeType,
      );

      // Parse response (now async to avoid blocking)
      final ingredients = await _parseIngredientResponse(result.data);

      // Filter by confidence threshold
      final filteredIngredients =
          ingredients.where((ing) => ing.confidence >= minConfidence).toList();

      // Group ingredients if enabled
      final finalIngredients = enableGrouping
          ? _groupIngredients(filteredIngredients)
          : filteredIngredients;

      // Update quality metrics with actual ingredient count
      final updatedMetrics = ImageQualityMetrics(
        isBlurry: qualityMetrics.isBlurry,
        blurScore: qualityMetrics.blurScore,
        isLowLight: qualityMetrics.isLowLight,
        brightnessScore: qualityMetrics.brightnessScore,
        hasGoodContrast: qualityMetrics.hasGoodContrast,
        contrastScore: qualityMetrics.contrastScore,
        estimatedIngredientCount: finalIngredients.length,
        qualityAssessment: qualityMetrics.qualityAssessment,
      );

      return ImageAnalysisResult(
        ingredients: finalIngredients,
        qualityMetrics: updatedMetrics,
        success: true,
        processingTimeMs: DateTime.now().difference(startTime).inMilliseconds,
      );
    } on ServerException catch (e) {
      return ImageAnalysisResult(
        ingredients: [],
        qualityMetrics: qualityMetrics ??
            ImageQualityMetrics(
              isBlurry: false,
              blurScore: 0.0,
              isLowLight: false,
              brightnessScore: 0.0,
              hasGoodContrast: false,
              contrastScore: 0.0,
              estimatedIngredientCount: 0,
              qualityAssessment: 'unknown',
            ),
        errorMessage: e.message,
        success: false,
        processingTimeMs: DateTime.now().difference(startTime).inMilliseconds,
      );
    } on DataParsingException catch (e) {
      return ImageAnalysisResult(
        ingredients: [],
        qualityMetrics: qualityMetrics ??
            ImageQualityMetrics(
              isBlurry: false,
              blurScore: 0.0,
              isLowLight: false,
              brightnessScore: 0.0,
              hasGoodContrast: false,
              contrastScore: 0.0,
              estimatedIngredientCount: 0,
              qualityAssessment: 'unknown',
            ),
        errorMessage: e.message,
        success: false,
        processingTimeMs: DateTime.now().difference(startTime).inMilliseconds,
      );
    } catch (e) {
      return ImageAnalysisResult(
        ingredients: [],
        qualityMetrics: qualityMetrics ??
            ImageQualityMetrics(
              isBlurry: false,
              blurScore: 0.0,
              isLowLight: false,
              brightnessScore: 0.0,
              hasGoodContrast: false,
              contrastScore: 0.0,
              estimatedIngredientCount: 0,
              qualityAssessment: 'unknown',
            ),
        errorMessage: 'Image analysis failed: $e',
        success: false,
        processingTimeMs: DateTime.now().difference(startTime).inMilliseconds,
      );
    }
  }

  /// Analyze image quality metrics
  Future<ImageQualityMetrics> _analyzeImageQuality(Uint8List imageBytes) async {
    try {
      // Run heavy calculations in isolates to prevent UI blocking
      // Use compute() to run CPU-intensive operations on background threads
      final results = await Future.wait([
        compute(_calculateBlurScoreIsolate, imageBytes),
        compute(_calculateBrightnessIsolate, imageBytes),
        compute(_calculateContrastIsolate, imageBytes),
      ]);

      final blurScore = results[0];
      final brightnessScore = results[1];
      final contrastScore = results[2];

      final isBlurry = blurScore < 100.0;
      final isLowLight = brightnessScore < 50.0;
      final hasGoodContrast = contrastScore > 30.0;

      // Determine overall quality assessment
      String qualityAssessment;
      if (isBlurry || isLowLight || !hasGoodContrast) {
        qualityAssessment = 'poor';
      } else if (blurScore < 200 ||
          brightnessScore < 100 ||
          contrastScore < 50) {
        qualityAssessment = 'fair';
      } else if (blurScore < 400 ||
          brightnessScore < 150 ||
          contrastScore < 70) {
        qualityAssessment = 'good';
      } else {
        qualityAssessment = 'excellent';
      }

      return ImageQualityMetrics(
        isBlurry: isBlurry,
        blurScore: blurScore,
        isLowLight: isLowLight,
        brightnessScore: brightnessScore,
        hasGoodContrast: hasGoodContrast,
        contrastScore: contrastScore,
        estimatedIngredientCount: 0,
        qualityAssessment: qualityAssessment,
      );
    } catch (e) {
      // Return default metrics if analysis fails
      return ImageQualityMetrics(
        isBlurry: false,
        blurScore: 0.0,
        isLowLight: false,
        brightnessScore: 0.0,
        hasGoodContrast: false,
        contrastScore: 0.0,
        estimatedIngredientCount: 0,
        qualityAssessment: 'unknown',
      );
    }
  }

  /// Build advanced prompt for ingredient detection
  String _buildIngredientDetectionPrompt(
      double minConfidence, bool enableGrouping) {
    return '''
You are an expert food ingredient detector. Analyze the image and identify all visible food ingredients.

REQUIREMENTS:
- Detect ALL visible ingredients in the image
- Assign confidence scores (0.0 to 1.0) based on visibility certainty
- Group similar ingredients (e.g., "tomatoes" instead of "red tomato", "cherry tomato")
- Only include ingredients with confidence >= $minConfidence
- Categorize ingredients (vegetables, fruits, proteins, grains, spices, dairy, etc.)

RESPONSE FORMAT (JSON only, no markdown):
{
  "ingredients": [
    {
      "name": "ingredient name",
      "confidence": 0.95,
      "category": "vegetable",
      "metadata": {
        "color": "red",
        "state": "fresh",
        "quantity_estimate": "2-3 pieces"
      }
    }
  ]
}

QUALITY GUIDELINES:
- Be conservative with confidence scores
- If unsure about an ingredient, set confidence below threshold
- Prefer specific ingredient names over generic ones
- Include preparation state if visible (chopped, sliced, whole)
- Estimate quantity when possible

Return ONLY valid JSON, no additional text.''';
  }

  /// Parse ingredient response from Gemini
  Future<List<DetectedIngredient>> _parseIngredientResponse(
      String response) async {
    try {
      // Remove markdown code blocks if present
      String jsonString = response.trim();
      if (jsonString.contains('```json')) {
        final jsonMatch =
            RegExp(r'```json\n([\s\S]*?)\n```').firstMatch(jsonString);
        if (jsonMatch != null && jsonMatch.group(1) != null) {
          jsonString = jsonMatch.group(1)!;
        }
      } else if (jsonString.contains('```')) {
        final jsonMatch =
            RegExp(r'```\n?([\s\S]*?)\n?```').firstMatch(jsonString);
        if (jsonMatch != null && jsonMatch.group(1) != null) {
          jsonString = jsonMatch.group(1)!;
        }
      }

      // Use compute to parse JSON in isolate, preventing main thread blocking
      final ingredients =
          await compute(_parseJsonIngredientsIsolate, jsonString);
      return ingredients;
    } catch (e) {
      // Return empty list on parse error
      return [];
    }
  }

  /// Group similar ingredients to avoid duplicates
  List<DetectedIngredient> _groupIngredients(
      List<DetectedIngredient> ingredients) {
    final grouped = <String, DetectedIngredient>{};

    for (final ingredient in ingredients) {
      final normalizedName = ingredient.name.toLowerCase().trim();

      // Check for similar names (simple grouping logic)
      final existingKey = grouped.keys.firstWhere(
        (key) => _areSimilarIngredients(key, normalizedName),
        orElse: () => normalizedName,
      );

      if (grouped.containsKey(existingKey)) {
        // Merge with existing, keep higher confidence
        final existing = grouped[existingKey]!;
        if (ingredient.confidence > existing.confidence) {
          grouped[existingKey] = ingredient;
        }
      } else {
        grouped[normalizedName] = ingredient;
      }
    }

    return grouped.values.toList();
  }

  /// Check if two ingredient names are similar
  bool _areSimilarIngredients(String name1, String name2) {
    // Simple similarity check - can be enhanced with more sophisticated algorithms
    if (name1 == name2) return true;

    // Check if one is a substring of the other
    if (name1.contains(name2) || name2.contains(name1)) return true;

    // Check for common variations
    final variations = {
      'tomato': ['tomatoes', 'tomato'],
      'onion': ['onions', 'onion'],
      'garlic': ['garlic cloves', 'garlic'],
      'pepper': ['peppers', 'pepper'],
    };

    for (final entry in variations.entries) {
      if (name1.contains(entry.key) && name2.contains(entry.key)) return true;
      if (entry.value.contains(name1) && entry.value.contains(name2)) {
        return true;
      }
    }

    return false;
  }
}

// ============================================================================
// ISOLATE FUNCTIONS FOR IMAGE PROCESSING
// These top-level functions run in background isolates to prevent UI blocking
// ============================================================================

/// Calculate blur score using Laplacian variance (runs in isolate)
double _calculateBlurScoreIsolate(Uint8List imageBytes) {
  final image = img.decodeImage(imageBytes);
  if (image == null) return 0.0;

  final grayscale = img.grayscale(image);
  final kernel = [
    0.0,
    1.0,
    0.0,
    1.0,
    -4.0,
    1.0,
    0.0,
    1.0,
    0.0,
  ];

  final laplacian = img.convolution(grayscale, filter: kernel);

  double sum = 0;
  double sumSquared = 0;
  int count = 0;

  for (int y = 0; y < laplacian.height; y++) {
    for (int x = 0; x < laplacian.width; x++) {
      final pixel = laplacian.getPixel(x, y);
      final value = pixel.r.toDouble();
      sum += value;
      sumSquared += value * value;
      count++;
    }
  }

  final mean = sum / count;
  return (sumSquared / count) - (mean * mean);
}

/// Calculate average brightness (runs in isolate)
double _calculateBrightnessIsolate(Uint8List imageBytes) {
  final image = img.decodeImage(imageBytes);
  if (image == null) return 0.0;

  double totalBrightness = 0;
  int count = 0;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final brightness = (pixel.r + pixel.g + pixel.b) / 3;
      totalBrightness += brightness;
      count++;
    }
  }

  return totalBrightness / count;
}

/// Calculate contrast using standard deviation (runs in isolate)
double _calculateContrastIsolate(Uint8List imageBytes) {
  final image = img.decodeImage(imageBytes);
  if (image == null) return 0.0;

  final brightnesses = <double>[];

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final brightness = (pixel.r + pixel.g + pixel.b) / 3;
      brightnesses.add(brightness);
    }
  }

  final mean = brightnesses.reduce((a, b) => a + b) / brightnesses.length;
  final variance =
      brightnesses.map((b) => (b - mean) * (b - mean)).reduce((a, b) => a + b) /
          brightnesses.length;

  return sqrt(variance);
}

/// Parse JSON ingredients in isolate to prevent main thread blocking
List<DetectedIngredient> _parseJsonIngredientsIsolate(String jsonString) {
  try {
    final parsed = json.decode(jsonString) as Map<String, dynamic>;
    final ingredientsList = parsed['ingredients'] as List<dynamic>?;

    if (ingredientsList == null) {
      return [];
    }

    return ingredientsList
        .map(
            (item) => DetectedIngredient.fromJson(item as Map<String, dynamic>))
        .toList();
  } catch (e) {
    return [];
  }
}
