/// Recipe image resolution service.
///
/// Strategy (in priority order):
///   1. If RecipeModel.imageUrl is non-empty → use it directly (AI-provided).
///   2. Build a deterministic Unsplash Source URL from the recipe title/category.
///      Unsplash Source is free, needs no API key, returns a relevant photo,
///      and is served via Cloudflare CDN — ~50–100ms globally.
///   3. Fallback: local category-coloured gradient (zero network, always works).
///
/// Why NOT generate images with Gemini/Imagen:
///   - Imagen API is not in the free tier and adds 3–8s latency per recipe.
///   - Unsplash gives real food photography that's more appealing than generated art.
///   - The imagePrompt field from Gemini is used as the Unsplash keyword.
library;

import 'package:flutter/material.dart';

/// Resolved image source for a recipe.
sealed class RecipeImageSource {
  const RecipeImageSource();
}

/// A fully-qualified HTTPS URL.
final class RecipeNetworkImage extends RecipeImageSource {
  const RecipeNetworkImage(this.url);
  final String url;
}

/// A category-themed gradient (no network needed).
final class RecipeGradientImage extends RecipeImageSource {
  const RecipeGradientImage({required this.colors});
  final List<Color> colors;
}

abstract final class RecipeImageService {
  /// Unsplash Source base — returns 800×600 food photos, Cloudflare CDN.
  static const _unsplashBase = 'https://source.unsplash.com/800x600/?';

  /// Returns the best available image source for a recipe.
  static RecipeImageSource resolve({
    String? imageUrl,
    String? imagePrompt,
    required String title,
    required String category,
  }) {
    // 1. Direct URL already in the model (e.g. previously fetched).
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return RecipeNetworkImage(imageUrl);
    }

    // 2. Build an Unsplash URL from the AI-generated imagePrompt or title.
    final keyword = _buildKeyword(imagePrompt, title, category);
    if (keyword.isNotEmpty) {
      final encoded = Uri.encodeComponent(keyword);
      return RecipeNetworkImage('$_unsplashBase$encoded');
    }

    // 3. Category gradient fallback.
    return RecipeGradientImage(colors: _gradientForCategory(category));
  }

  static String _buildKeyword(
    String? imagePrompt,
    String title,
    String category,
  ) {
    if (imagePrompt != null && imagePrompt.trim().isNotEmpty) {
      // Use the AI-crafted scene description — most specific.
      return imagePrompt.trim();
    }
    // Compose from title + "food photography" for better image quality.
    return '${title.trim()} food';
  }

  static List<Color> _gradientForCategory(String category) {
    return switch (category.toLowerCase()) {
      'breakfast' => const [Color(0xFFFFA726), Color(0xFFFF7043)],
      'lunch' => const [Color(0xFF66BB6A), Color(0xFF26A69A)],
      'dinner' => const [Color(0xFF5C6BC0), Color(0xFF3949AB)],
      'snack' => const [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
      'dessert' => const [Color(0xFFEC407A), Color(0xFFC2185B)],
      _ => const [Color(0xFF42A5F5), Color(0xFF1E88E5)],
    };
  }
}
