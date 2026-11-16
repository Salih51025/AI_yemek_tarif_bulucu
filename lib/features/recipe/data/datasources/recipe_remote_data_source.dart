/// Remote data source: Gemini recipe generation + optional Supabase edge vision.
library;

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';

import '../../../../core/debug/agent_debug_log.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/ai/recipe_generation_service.dart';
import '../../../../core/utils/image_compressor.dart';
import '../../domain/models/ingredient_input_model.dart';
import '../../domain/models/recipe_generation_response.dart';

class RecipeRemoteDataSource {
  RecipeRemoteDataSource({
    required DioClient dioClient,
    required String supabaseUrl,
    required RecipeGenerationService recipeGenerationService,
    required Locale? locale,
  })  : _dioClient = dioClient,
        _supabaseUrl = supabaseUrl,
        _recipeGenerationService = recipeGenerationService,
        _locale = locale;

  final DioClient _dioClient;
  final String _supabaseUrl;
  final RecipeGenerationService _recipeGenerationService;
  final Locale? _locale;

  String get _languageCode => (_locale?.languageCode ?? 'en').toLowerCase();

  Future<RecipeGenerationResponse> generateRecipes(
    IngredientInputModel input, {
    File? imageFile,
    Uint8List? imageBytes,
    String? imageMimeType,
  }) async {
    if (!input.isValid() && imageFile == null && imageBytes == null) {
      throw const DataParsingException(
        message:
            'Invalid input: provide ingredients or an image',
        code: 'invalid_input',
      );
    }

    if (imageFile != null || imageBytes != null) {
      // #region agent log
      AgentDebugLog.log(
        location: 'recipe_remote_data_source.dart:generateRecipes',
        message: 'image_path_start',
        hypothesisId: 'H10',
        runId: 'post-fix',
        data: {
          'hasFile': imageFile != null,
          'hasBytes': imageBytes != null,
          'ingredientCount': input.ingredients.length,
        },
      );
      // #endregion

      final compressed = await _compressForAi(
        imageFile: imageFile,
        imageBytes: imageBytes,
        imageMimeType: imageMimeType,
      );

      final result = await _recipeGenerationService.generateFromImage(
        compressed.bytes,
        compressed.mimeType,
        extraIngredients: input.ingredients,
        config: RecipeGenerationConfig(language: _languageCode),
      );
      return result.response;
    }

    if (input.ingredients.isNotEmpty) {
      // #region agent log
      AgentDebugLog.log(
        location: 'recipe_remote_data_source.dart:generateRecipes',
        message: 'ingredient_path_config',
        hypothesisId: 'H-LOC2',
        runId: 'pre-fix',
        data: {
          'ingredientCount': input.ingredients.length,
          'configProvided': true,
          'languageWillFallbackToDefault': false,
          'selectedLanguage': _languageCode,
        },
      );
      // #endregion
      final result = await _recipeGenerationService.generateFromIngredients(
        input.ingredients,
        config: RecipeGenerationConfig(language: _languageCode),
      );
      return result.response;
    }

    throw const DataParsingException(
      message: 'No valid input for recipe generation',
      code: 'no_valid_input',
    );
  }

  Future<CompressedImage> _compressForAi({
    File? imageFile,
    Uint8List? imageBytes,
    String? imageMimeType,
  }) async {
    try {
      if (imageBytes != null) {
        return ImageCompressor.fromBytes(
          imageBytes,
          mimeType: imageMimeType ?? 'image/jpeg',
        );
      }
      if (imageFile != null) {
        return ImageCompressor.fromFile(imageFile);
      }
      throw const DataParsingException(
        message: 'No image data to compress',
        code: 'no_image_data',
      );
    } on FileSystemException catch (e) {
      throw DataParsingException(
        message:
            'Could not read image file. Re-pick the photo from gallery. (${e.message})',
        code: 'image_read_failed',
      );
    }
  }

  Future<List<String>> processIngredientImage(String photoUrl) async {
    try {
      final edgeFunctionUrl =
          '$_supabaseUrl${ApiConstants.supabaseEdgeFunctionBase}'
          '/${AppConstants.supabaseEdgeFunctionProcessImage}';

      final response = await _dioClient.post(
        edgeFunctionUrl,
        data: {'photo_url': photoUrl},
        options: Options(
          headers: {
            ...ApiConstants.defaultHeaders,
            'Authorization': 'Bearer ${_getAuthToken()}',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Edge Function returned status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final responseData = response.data;
      if (responseData == null) {
        throw const DataParsingException(
          message: 'Empty response from Edge Function',
          code: 'empty_response',
        );
      }

      if (responseData['success'] == false) {
        throw ServerException(
          message: responseData['error'] ?? 'Edge Function error',
          code: responseData['code'] ?? 'edge_function_error',
        );
      }

      final ingredients = responseData['ingredients'] as List<dynamic>?;
      if (ingredients == null) {
        throw const DataParsingException(
          message: 'No ingredients found in response',
          code: 'no_ingredients',
        );
      }

      return ingredients.map((e) => e.toString()).toList();
    } on DataParsingException {
      rethrow;
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      throw NetworkException(
        message: 'Network error calling Edge Function: ${e.message}',
        code: e.type.name,
      );
    } catch (e) {
      throw DataParsingException(
        message: 'Error parsing Edge Function response: $e',
        code: 'parse_error',
      );
    }
  }

  String _getAuthToken() => '';
}
