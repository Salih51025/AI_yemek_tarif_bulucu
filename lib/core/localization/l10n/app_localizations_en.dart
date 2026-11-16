// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'AI Chef';

  @override
  String get navGenerate => 'Generate';

  @override
  String get navTrending => 'Trending';

  @override
  String get navSaved => 'Saved';

  @override
  String get navProfile => 'Profile';

  @override
  String get generateTitle => 'Create with AI';

  @override
  String get generateHero =>
      'Tell us what you have.\nWe\'ll craft recipes you\'ll love.';

  @override
  String get ingredientPhotoTitle => 'Ingredient photo';

  @override
  String get tapToAddPhoto => 'Tap to add photo';

  @override
  String get ingredientsCardTitle => 'What\'s in your kitchen?';

  @override
  String get ingredientsCardSubtitle => 'Add items or snap a photo above';

  @override
  String get ingredientHint => 'e.g. tomato, chicken…';

  @override
  String get noIngredientsYet => 'No ingredients yet';

  @override
  String get generateButton => 'Generate Recipes';

  @override
  String get scanButton => 'Scan';

  @override
  String get shareButton => 'Share';

  @override
  String get saveButton => 'Save';

  @override
  String get savedButton => 'Saved';

  @override
  String get aiCookingTitle => 'AI Chef is cooking';

  @override
  String get aiThinking1 => 'Analyzing your ingredients…';

  @override
  String get aiThinking2 => 'Searching best recipes…';

  @override
  String get aiThinking3 => 'Creating personalized meals…';

  @override
  String get aiThinking4 => 'Almost ready…';

  @override
  String get favoritesTitle => 'Saved Recipes';

  @override
  String get favoritesEmptyTitle => 'No saved recipes yet';

  @override
  String get favoritesEmptyBody =>
      'Heart any recipe while browsing — it\'ll appear here instantly.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get preferencesTitle => 'Preferences';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get appearanceSystem => 'System';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get hometownTitle => 'Hometown';

  @override
  String get rememberLocationTitle => 'Remember my location';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageJapanese => '日本語';

  @override
  String recipesFound(Object count) {
    return '$count recipes found';
  }

  @override
  String get generatedRecipesTitle => 'Generated Recipes';

  @override
  String get newSearch => 'New Search';

  @override
  String get noRecipesYetTitle => 'No recipes yet';

  @override
  String get noRecipesYetBody =>
      'Add ingredients or upload a photo\nto generate recipes';

  @override
  String get startNewSearch => 'Start New Search';

  @override
  String get recipeGenerationFailedTitle => 'Recipe generation failed';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get retry => 'Retry';

  @override
  String get ingredientsLabel => 'Ingredients';

  @override
  String get stepsLabel => 'Steps';

  @override
  String get instructionsLabel => 'Instructions';

  @override
  String get showMore => 'Show More';

  @override
  String get showLess => 'Show Less';

  @override
  String get couldNotPickImage => 'Could not pick image';

  @override
  String get addIngredientsOrUpload => 'Add ingredients or upload a photo';

  @override
  String get okLabel => 'OK';

  @override
  String get noTrendingRecipesYet => 'No trending recipes yet';

  @override
  String get beFirstToSaveRecipe => 'Be the first to save a recipe!';

  @override
  String get preparingKitchen => 'Preparing your kitchen…';

  @override
  String minutesShort(Object value) {
    return '$value min';
  }

  @override
  String servingsLabel(Object value) {
    return '$value servings';
  }

  @override
  String caloriesLabel(Object value) {
    return '$value cal';
  }
}
