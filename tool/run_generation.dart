import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:ai_chef/core/services/ai/recipe_generation_service.dart';

/// Headless entry: `flutter run -t tool/run_generation.dart -d chrome`
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final service = RecipeGenerationService();
  final result = await service.generateFromIngredients(
    ['egg', 'tomato'],
  );

  final line = jsonEncode({
    'sessionId': 'df1795',
    'runId': 'app_layer',
    'hypothesisId': 'H1',
    'message': 'app_layer_success',
    'data': {
      'count': result.response.recipes.length,
      'model': result.modelUsed,
    },
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  });

  for (final path in ['debug-df1795.log', '.cursor/debug-df1795.log']) {
    File(path).writeAsStringSync('$line\n', mode: FileMode.append);
  }

  print('OK ${result.response.recipes.length} recipes via ${result.modelUsed}');
  exit(0);
}
