/// Platform-native recipe sharing via share_plus.
library;

import 'package:share_plus/share_plus.dart';

import '../recipe/domain/models/recipe_model.dart';

class ShareService {
  const ShareService();

  Future<void> shareRecipe(RecipeModel recipe) async {
    final text = formatRecipeText(recipe);
    await Share.share(
      text,
      subject: recipe.title,
    );
  }

  /// Plain-text recipe card for SMS / WhatsApp / system sheet.
  static String formatRecipeText(RecipeModel recipe) {
    final buffer = StringBuffer()
      ..writeln('🍳 ${recipe.title}')
      ..writeln();

    if (recipe.description != null && recipe.description!.trim().isNotEmpty) {
      buffer.writeln(recipe.description!.trim());
      buffer.writeln();
    }

    buffer.writeln('⏱ ${recipe.cookingTimeMinutes} min · ${recipe.difficulty} · ${recipe.category}');
    buffer.writeln();

    if (recipe.ingredients.isNotEmpty) {
      buffer.writeln('Ingredients:');
      for (final i in recipe.ingredients) {
        final qty = i.quantity?.trim();
        buffer.writeln(
          qty != null && qty.isNotEmpty ? '• ${i.name} — $qty' : '• ${i.name}',
        );
      }
      buffer.writeln();
    }

    if (recipe.steps.isNotEmpty) {
      buffer.writeln('Steps:');
      for (final step in recipe.steps) {
        buffer.writeln('${step.stepNumber}. ${step.instruction}');
        if (step.tip != null && step.tip!.trim().isNotEmpty) {
          buffer.writeln('   Tip: ${step.tip}');
        }
      }
      buffer.writeln();
    }

    if (recipe.imageUrl != null && recipe.imageUrl!.trim().isNotEmpty) {
      buffer.writeln('Image: ${recipe.imageUrl!.trim()}');
    }

    final body = buffer.toString().trim();
    const maxLen = 6000;
    if (body.length <= maxLen) return body;
    return '${body.substring(0, maxLen - 20)}\n\n… (truncated)';
  }
}
