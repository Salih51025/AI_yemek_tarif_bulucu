// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'AI Chef';

  @override
  String get navGenerate => 'Erstellen';

  @override
  String get navTrending => 'Trends';

  @override
  String get navSaved => 'Gespeichert';

  @override
  String get navProfile => 'Profil';

  @override
  String get generateTitle => 'Mit KI erstellen';

  @override
  String get generateHero =>
      'Sag uns, was du hast.\nWir erstellen Rezepte, die du lieben wirst.';

  @override
  String get ingredientPhotoTitle => 'Zutatenfoto';

  @override
  String get tapToAddPhoto => 'Tippen, um ein Foto hinzuzufügen';

  @override
  String get ingredientsCardTitle => 'Was ist in deiner Küche?';

  @override
  String get ingredientsCardSubtitle =>
      'Füge Zutaten hinzu oder mache oben ein Foto';

  @override
  String get ingredientHint => 'z.B. Tomate, Hähnchen…';

  @override
  String get noIngredientsYet => 'Noch keine Zutaten';

  @override
  String get generateButton => 'Rezepte generieren';

  @override
  String get scanButton => 'Scannen';

  @override
  String get shareButton => 'Teilen';

  @override
  String get saveButton => 'Speichern';

  @override
  String get savedButton => 'Gespeichert';

  @override
  String get aiCookingTitle => 'AI Chef kocht';

  @override
  String get aiThinking1 => 'Zutaten werden analysiert…';

  @override
  String get aiThinking2 => 'Beste Rezepte werden gesucht…';

  @override
  String get aiThinking3 => 'Personalisierte Gerichte werden erstellt…';

  @override
  String get aiThinking4 => 'Fast fertig…';

  @override
  String get favoritesTitle => 'Gespeicherte Rezepte';

  @override
  String get favoritesEmptyTitle => 'Noch keine gespeicherten Rezepte';

  @override
  String get favoritesEmptyBody =>
      'Tippe beim Stöbern auf das Herz — dann erscheint es hier sofort.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get preferencesTitle => 'Einstellungen';

  @override
  String get appearanceTitle => 'Darstellung';

  @override
  String get appearanceSystem => 'System';

  @override
  String get appearanceLight => 'Hell';

  @override
  String get appearanceDark => 'Dunkel';

  @override
  String get hometownTitle => 'Heimat';

  @override
  String get rememberLocationTitle => 'Standort merken';

  @override
  String get languageTitle => 'Sprache';

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
    return '$count Rezepte gefunden';
  }

  @override
  String get generatedRecipesTitle => 'Generierte Rezepte';

  @override
  String get newSearch => 'Neue Suche';

  @override
  String get noRecipesYetTitle => 'Noch keine Rezepte';

  @override
  String get noRecipesYetBody =>
      'Füge Zutaten hinzu oder lade ein Foto hoch, um Rezepte zu generieren';

  @override
  String get startNewSearch => 'Neue Suche starten';

  @override
  String get recipeGenerationFailedTitle => 'Rezepterstellung fehlgeschlagen';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get retry => 'Wiederholen';

  @override
  String get ingredientsLabel => 'Zutaten';

  @override
  String get stepsLabel => 'Schritte';

  @override
  String get instructionsLabel => 'Anleitung';

  @override
  String get showMore => 'Mehr anzeigen';

  @override
  String get showLess => 'Weniger anzeigen';

  @override
  String get couldNotPickImage => 'Bild konnte nicht ausgewählt werden';

  @override
  String get addIngredientsOrUpload => 'Zutaten hinzufügen oder Foto hochladen';

  @override
  String get okLabel => 'OK';

  @override
  String get noTrendingRecipesYet => 'Noch keine Trend-Rezepte';

  @override
  String get beFirstToSaveRecipe => 'Speichere als Erste:r ein Rezept!';

  @override
  String get preparingKitchen => 'Deine Küche wird vorbereitet…';

  @override
  String minutesShort(Object value) {
    return '$value Min.';
  }

  @override
  String servingsLabel(Object value) {
    return '$value Portionen';
  }

  @override
  String caloriesLabel(Object value) {
    return '$value kcal';
  }
}
