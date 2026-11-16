/// Core AI service for Google Gemini API integration.
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart' as gemini;

import '../../debug/agent_debug_log.dart';
import '../../errors/exceptions.dart';
import '../../security/env_config.dart';

/// Configuration for Gemini service requests.
class GeminiConfig {
  final String model;
  final Duration timeout;
  final int maxRetries;
  final double temperature;
  final int maxOutputTokens;
  final bool jsonMode;

  const GeminiConfig({
    this.model = EnvConfig.geminiModel,
    this.timeout = const Duration(seconds: 45),
    this.maxRetries = 3,
    this.temperature = 0.4,
    this.maxOutputTokens = 4096,
    this.jsonMode = true,
  });

  factory GeminiConfig.premium() {
    return const GeminiConfig(
      model: EnvConfig.geminiModelPro,
      timeout: Duration(seconds: 60),
      maxRetries: 4,
      temperature: 0.5,
      maxOutputTokens: 8192,
      jsonMode: true,
    );
  }
}

/// Result of a Gemini API call with metadata.
class GeminiResult<T> {
  final T data;
  final String modelUsed;
  final int? tokensUsed;
  final Duration duration;
  final int attemptCount;

  const GeminiResult({
    required this.data,
    required this.modelUsed,
    this.tokensUsed,
    required this.duration,
    required this.attemptCount,
  });
}

/// Production Gemini client: retries, timeout, JSON mode, model fallback.
class GeminiService {
  GeminiService({
    GeminiConfig? config,
    String? apiKey,
  })  : _config = config ?? const GeminiConfig(),
        _apiKey = apiKey ?? EnvConfig.geminiApiKey;

  final GeminiConfig _config;
  final String _apiKey;

  Future<GeminiResult<String>> generateText(
    String prompt, {
    String? systemInstruction,
    GeminiConfig? config,
  }) {
    return _generate(
      prompt: prompt,
      systemInstruction: systemInstruction,
      config: config,
      imageBytes: null,
      imageMimeType: null,
    );
  }

  Future<GeminiResult<String>> generateMultiModal(
    String prompt, {
    Uint8List? imageBytes,
    String? imageMimeType,
    String? systemInstruction,
    GeminiConfig? config,
  }) {
    return _generate(
      prompt: prompt,
      systemInstruction: systemInstruction,
      config: config,
      imageBytes: imageBytes,
      imageMimeType: imageMimeType,
    );
  }

  Future<GeminiResult<String>> _generate({
    required String prompt,
    String? systemInstruction,
    GeminiConfig? config,
    Uint8List? imageBytes,
    String? imageMimeType,
  }) async {
    final effectiveConfig = config ?? _config;
    var attempt = 0;
    var modelName = effectiveConfig.model;
    var useJsonMode = effectiveConfig.jsonMode;

    while (attempt < effectiveConfig.maxRetries) {
      attempt++;
      final startTime = DateTime.now();

      try {
        final model = _model(
          modelName,
          systemInstruction: systemInstruction,
        );

        final parts = <gemini.Part>[gemini.TextPart(prompt)];
        if (imageBytes != null && imageMimeType != null) {
          parts.add(gemini.DataPart(imageMimeType, imageBytes));
        }

        final content = await _executeWithTimeout(
          model.generateContent(
            [gemini.Content.multi(parts)],
            generationConfig: _generationConfig(
              effectiveConfig,
              jsonMode: useJsonMode,
            ),
          ),
          effectiveConfig.timeout,
        );

        final text = _extractText(content)?.trim();
        if (text == null || text.isEmpty) {
          throw const DataParsingException(
            message: 'Gemini returned empty response',
            code: 'empty_response',
          );
        }

        // #region agent log
        AgentDebugLog.log(
          location: 'gemini_service.dart:_generate',
          message: 'gemini_ok',
          hypothesisId: 'H1',
          data: {
            'model': modelName,
            'attempt': attempt,
            'responseChars': text.length,
            'hasImage': imageBytes != null,
          },
        );
        // #endregion

        return GeminiResult(
          data: text,
          modelUsed: modelName,
          duration: DateTime.now().difference(startTime),
          attemptCount: attempt,
        );
      } on TimeoutException {
        // #region agent log
        AgentDebugLog.log(
          location: 'gemini_service.dart:_generate',
          message: 'gemini_timeout',
          hypothesisId: 'H2',
          data: {'attempt': attempt, 'model': modelName},
        );
        // #endregion
        if (attempt < effectiveConfig.maxRetries) {
          await _backoff(attempt);
          continue;
        }
        throw ServerException(
          message:
              'Gemini API timeout after ${effectiveConfig.timeout.inSeconds}s',
          code: 'timeout',
        );
      } on gemini.GenerativeAIException catch (e) {
        // #region agent log
        AgentDebugLog.log(
          location: 'gemini_service.dart:_generate',
          message: 'gemini_api_error',
          hypothesisId: 'H1',
          data: {
            'model': modelName,
            'attempt': attempt,
            'error': e.message.split('\n').first,
          },
        );
        // #endregion
        if (attempt == 1 &&
            modelName != EnvConfig.geminiModelFallback &&
            _shouldTryFallbackModel(e)) {
          modelName = EnvConfig.geminiModelFallback;
          continue;
        }
        if (attempt < effectiveConfig.maxRetries) {
          await _backoff(attempt);
          continue;
        }
        throw ServerException(
          message: _userFacingMessage(e.message),
          code: _errorCode(e.message),
        );
      } on DataParsingException {
        rethrow;
      } on FormatException {
        // #region agent log
        AgentDebugLog.log(
          location: 'gemini_service.dart:_generate',
          message: 'format_exception',
          hypothesisId: 'H12',
          data: {'attempt': attempt, 'useJsonMode': useJsonMode},
        );
        // #endregion
        useJsonMode = false;
        if (attempt < effectiveConfig.maxRetries) {
          await _backoff(attempt);
          continue;
        }
        throw const ServerException(
          message: 'AI returned invalid data. Try again.',
          code: 'invalid_response',
        );
      } catch (e) {
        if (attempt < effectiveConfig.maxRetries) {
          await _backoff(attempt);
          continue;
        }
        throw ServerException(
          message: 'Unexpected Gemini error: $e',
          code: 'unknown_error',
        );
      }
    }

    throw ServerException(
      message: 'Failed after ${effectiveConfig.maxRetries} attempts',
      code: 'max_retries_exceeded',
    );
  }

  gemini.GenerativeModel _model(
    String modelName, {
    String? systemInstruction,
  }) {
    return gemini.GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      systemInstruction: systemInstruction != null
          ? gemini.Content.system(systemInstruction)
          : null,
    );
  }

  gemini.GenerationConfig _generationConfig(
    GeminiConfig config, {
    required bool jsonMode,
  }) {
    return gemini.GenerationConfig(
      temperature: config.temperature,
      maxOutputTokens: config.maxOutputTokens,
      responseMimeType: jsonMode ? 'application/json' : null,
    );
  }

  String? _extractText(gemini.GenerateContentResponse response) {
    final direct = response.text;
    if (direct != null && direct.isNotEmpty) return direct;
    for (final candidate in response.candidates) {
      for (final part in candidate.content.parts) {
        if (part is gemini.TextPart && part.text.isNotEmpty) {
          return part.text;
        }
      }
    }
    return null;
  }

  Future<T> _executeWithTimeout<T>(Future<T> future, Duration timeout) {
    return future.timeout(timeout);
  }

  Future<void> _backoff(int attempt) async {
    await Future<void>.delayed(
      Duration(milliseconds: 500 * (1 << (attempt - 1))),
    );
  }

  bool _shouldTryFallbackModel(gemini.GenerativeAIException error) {
    final message = error.message.toLowerCase();
    return message.contains('not found') ||
        message.contains('not supported') ||
        message.contains('quota') ||
        message.contains('rate') ||
        message.contains('503') ||
        message.contains('unavailable');
  }

  String _userFacingMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('quota') || lower.contains('rate')) {
      return 'AI quota reached. Wait a minute or use a new API key in .env.';
    }
    if (lower.contains('not found')) {
      return 'AI model unavailable. Update the app or check GEMINI model settings.';
    }
    return 'Gemini API error: ${raw.split('\n').first}';
  }

  String _errorCode(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('quota')) return 'quota_exceeded';
    if (lower.contains('not found')) return 'model_not_found';
    return 'gemini_error';
  }
}
