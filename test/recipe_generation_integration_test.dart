import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:ai_chef/core/services/ai/recipe_generation_service.dart';

void _log(String message, Map<String, Object?> data) {
  for (final path in ['debug-df1795.log', '.cursor/debug-df1795.log']) {
    try {
      final file = File(path);
      if (path.contains('.')) {
        file.parent.createSync(recursive: true);
      }
      file.writeAsStringSync(
        '${jsonEncode({
          'sessionId': 'df1795',
          'runId': 'integration',
          'hypothesisId': 'H1',
          'message': message,
          'data': data,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        })}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('end-to-end recipe generation from text ingredients', () async {
    await dotenv.load(fileName: '.env');
    final key = dotenv.env['GEMINI_API_KEY'] ?? '';
    expect(key.isNotEmpty, true, reason: 'GEMINI_API_KEY missing in .env');

    _log('integration_start', {'keyLength': key.length});

    final service = RecipeGenerationService();
    final result = await service.generateFromIngredients(
      ['egg', 'tomato', 'cheese'],
    );

    expect(result.response.recipes, isNotEmpty);
    _log('integration_success', {
      'recipeCount': result.response.recipes.length,
      'titles': result.response.recipes.map((r) => r.title).toList(),
      'model': result.modelUsed,
    });
  }, timeout: const Timeout(Duration(minutes: 2)));
}
