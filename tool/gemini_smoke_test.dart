import 'dart:convert';
import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

/// Verifies EnvConfig model IDs against the live API (run from project root).
Future<void> main() async {
  final key = _readKey();
  if (key.isEmpty) exit(1);

  const primary = 'gemini-2.5-flash';
  const fallback = 'gemini-flash-latest';

  for (final modelName in [primary, fallback]) {
    stdout.writeln('--- $modelName ---');
    try {
      final model = GenerativeModel(
        model: modelName,
        apiKey: key,
        systemInstruction: Content.system('Output ONLY valid JSON.'),
      );
      final response = await model.generateContent(
        [
          Content.text(
            'Ingredients: chicken, rice. Return {"recipes":[{"title":"x","description":"d","difficulty":"Easy","time":"20 min","calories":400,"imagePrompt":"food","ingredients":["chicken"],"steps":["cook"]}]}',
          ),
        ],
        generationConfig: GenerationConfig(
          temperature: 0.2,
          responseMimeType: 'application/json',
        ),
      );
      final text = response.text ?? '';
      json.decode(text);
      File('debug-df1795.log').writeAsStringSync(
        '${jsonEncode({
          'sessionId': 'df1795',
          'runId': 'post-fix-verify',
          'hypothesisId': 'H1',
          'message': 'env_models_ok',
          'data': {'model': modelName},
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        })}\n',
      );
      print('OK $modelName');
      exit(0);
    } catch (e) {
      print('ERR: ${e.toString().split('\n').first}');
    }
  }
  exit(2);
}

String _readKey() {
  for (final line in File('.env').readAsLinesSync()) {
    if (line.startsWith('GEMINI_API_KEY=')) {
      return line.substring('GEMINI_API_KEY='.length).trim();
    }
  }
  return '';
}
