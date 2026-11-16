import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:ai_chef/core/services/ai/recipe_generation_service.dart';

void _log(String message, Map<String, Object?> data) {
  final line = jsonEncode({
    'sessionId': 'df1795',
    'runId': 'integration_test',
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
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('generates recipes via app service layer', (tester) async {
    await dotenv.load(fileName: '.env');
    final key = dotenv.env['GEMINI_API_KEY'] ?? '';
    expect(key.isNotEmpty, true);

    _log('integration_test_start', {'keyLen': key.length});

    final service = RecipeGenerationService();
    final result = await service.generateFromIngredients(
      ['egg', 'tomato', 'onion'],
    );

    expect(result.response.recipes, isNotEmpty);

    _log('integration_test_success', {
      'count': result.response.recipes.length,
      'model': result.modelUsed,
      'titles': result.response.recipes.map((r) => r.title).toList(),
    });
  });
}
