import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chef/core/services/ai/recipe_ai_parser.dart';

void main() {
  const parser = RecipeAiParser();

  test('parses strict recipes envelope with string arrays', () {
    const raw = '''
{"recipes":[{"title":"Shakshuka","description":"Quick brunch","difficulty":"Easy","time":"25 min","calories":320,"imagePrompt":"shakshuka","ingredients":["egg","tomato"],"steps":["Simmer tomatoes","Add eggs"]}]}
''';

    final recipes = parser.parseSync(raw);
    expect(recipes, hasLength(1));
    expect(recipes.first.title, 'Shakshuka');
    expect(recipes.first.cookingTimeMinutes, 25);
    expect(recipes.first.ingredients, hasLength(2));
    expect(recipes.first.steps, hasLength(2));
  });
}
