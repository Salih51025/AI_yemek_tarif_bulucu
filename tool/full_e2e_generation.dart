import 'dart:convert';
import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../lib/core/services/ai/gemini_prompts.dart';

void _log(String message, Map<String, Object?> data) {
  final line = jsonEncode({
    'sessionId': 'df1795',
    'runId': 'full_e2e',
    'hypothesisId': 'H1',
    'message': message,
    'data': data,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  });
  for (final path in ['debug-df1795.log', '.cursor/debug-df1795.log']) {
    try {
      File(path).writeAsStringSync('$line\n', mode: FileMode.append);
    } catch (_) {}
  }
  stdout.writeln(line);
}

Future<void> main() async {
  final key = _readKey();
  if (key.isEmpty) {
    _log('no_api_key', {});
    exit(1);
  }

  const modelName = 'gemini-2.5-flash';
  final prompt = GeminiPrompts.recipeFromIngredients(
    ingredients: ['egg', 'tomato'],
    count: 2,
  );

  final model = GenerativeModel(
    model: modelName,
    apiKey: key,
    systemInstruction: Content.system(GeminiPrompts.recipeSystemInstruction),
  );

  _log('request_start', {'model': modelName});

  final response = await model.generateContent(
    [Content.text(prompt)],
    generationConfig: GenerationConfig(
      temperature: 0.2,
      responseMimeType: 'application/json',
      maxOutputTokens: 4096,
    ),
  );

  final text = response.text?.trim() ?? '';
  _log('response_received', {'chars': text.length});

  if (text.isEmpty) {
    _log('empty_response', {});
    exit(2);
  }

  final decoded = json.decode(text);
  final recipes = (decoded as Map)['recipes'] as List;
  _log('full_e2e_success', {'recipeCount': recipes.length});
}

String _readKey() {
  for (final line in File('.env').readAsLinesSync()) {
    if (line.startsWith('GEMINI_API_KEY=')) {
      return line.substring('GEMINI_API_KEY='.length).trim();
    }
  }
  return '';
}
