/// Compact, token-efficient prompts for structured Gemini recipe output.
library;

abstract final class GeminiPrompts {
  static const recipeSystemInstruction = '''
You are a professional chef assistant. Output ONLY valid JSON.
No markdown, no code fences, no commentary before or after the JSON object.
''';

  /// Strict envelope the model must return.
  static const recipeJsonSchemaHint = '''
{"recipes":[{"title":"","description":"","difficulty":"Easy|Medium|Hard","time":"30 min","calories":null,"imagePrompt":"","ingredients":[""],"steps":[""]}]}
''';

  static String recipeFromIngredients({
    required List<String> ingredients,
    required int count,
    String language = 'en',
    String? regionCountry,
    String? regionCity,
  }) {
    final list = ingredients.map((e) => e.trim()).where((e) => e.isNotEmpty).join(', ');
    final regionHint = _regionHint(regionCountry, regionCity);
    return '''
Given ingredients: $list
Language: $language$regionHint
Return exactly $count recipes as JSON matching:
$recipeJsonSchemaHint
Rules:
- "recipes" root key required
- "ingredients" and "steps" are string arrays (concise)
- "time" is human-readable (e.g. "25 min")
- "calories" integer or null
- "imagePrompt" short English scene for food photography
- Use only listed ingredients plus pantry staples (salt, oil, water)
''';
  }

  static String _regionHint(String? country, String? city) {
    if (country == null || country.isEmpty) return '';
    final cityPart = (city != null && city.isNotEmpty) ? ', $city' : '';
    return '\nPrefer traditional dishes from $country$cityPart when ingredients allow.';
  }

  static String recipeFromImage({
    required int count,
    String language = 'en',
    List<String> extraIngredients = const [],
  }) {
    final extras = extraIngredients
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join(', ');
    final extraLine = extras.isEmpty
        ? ''
        : '\nAlso use these user-listed ingredients: $extras';
    return '''
Analyze the food ingredient image. Language: $language$extraLine
Return exactly $count recipes as JSON matching:
$recipeJsonSchemaHint
Rules:
- Identify visible ingredients first, then suggest realistic home recipes
- Same schema as text mode; string arrays for ingredients and steps
''';
  }
}
