/// Application-wide constants used throughout the app.
/// 
/// This file contains static constants for app configuration,
/// storage paths, and other application-level settings.
class AppConstants {
  AppConstants._();

  /// Application name
  static const String appName = 'AI Chef';

  /// Firebase Storage path for ingredient photos
  static const String firebaseFridgeSnapsPath = 'fridge_snaps';

  /// Supabase Edge Function endpoints
  static const String supabaseEdgeFunctionGenerateRecipe = 'generate-recipe';
  static const String supabaseEdgeFunctionProcessImage = 'process-ingredient-image';

  /// Recipe difficulty levels
  static const List<String> recipeDifficultyLevels = [
    'Easy',
    'Medium',
    'Hard',
  ];

  /// Recipe categories
  static const List<String> recipeCategories = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
    'Dessert',
  ];

  /// Default pagination limit
  static const int defaultPaginationLimit = 20;

  /// Image upload max size in bytes (10MB)
  static const int maxImageSizeBytes = 10 * 1024 * 1024;

  /// Supported image formats
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png'];
}
