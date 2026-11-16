import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
    Locale('de'),
    Locale('ja')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'AI Chef'**
  String get appName;

  /// No description provided for @navGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get navGenerate;

  /// No description provided for @navTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get navTrending;

  /// No description provided for @navSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get navSaved;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @generateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create with AI'**
  String get generateTitle;

  /// No description provided for @generateHero.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you have.\nWe\'ll craft recipes you\'ll love.'**
  String get generateHero;

  /// No description provided for @ingredientPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredient photo'**
  String get ingredientPhotoTitle;

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get tapToAddPhoto;

  /// No description provided for @ingredientsCardTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s in your kitchen?'**
  String get ingredientsCardTitle;

  /// No description provided for @ingredientsCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add items or snap a photo above'**
  String get ingredientsCardSubtitle;

  /// No description provided for @ingredientHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. tomato, chicken…'**
  String get ingredientHint;

  /// No description provided for @noIngredientsYet.
  ///
  /// In en, this message translates to:
  /// **'No ingredients yet'**
  String get noIngredientsYet;

  /// No description provided for @generateButton.
  ///
  /// In en, this message translates to:
  /// **'Generate Recipes'**
  String get generateButton;

  /// No description provided for @scanButton.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanButton;

  /// No description provided for @shareButton.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @savedButton.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedButton;

  /// No description provided for @aiCookingTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Chef is cooking'**
  String get aiCookingTitle;

  /// No description provided for @aiThinking1.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your ingredients…'**
  String get aiThinking1;

  /// No description provided for @aiThinking2.
  ///
  /// In en, this message translates to:
  /// **'Searching best recipes…'**
  String get aiThinking2;

  /// No description provided for @aiThinking3.
  ///
  /// In en, this message translates to:
  /// **'Creating personalized meals…'**
  String get aiThinking3;

  /// No description provided for @aiThinking4.
  ///
  /// In en, this message translates to:
  /// **'Almost ready…'**
  String get aiThinking4;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Recipes'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved recipes yet'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Heart any recipe while browsing — it\'ll appear here instantly.'**
  String get favoritesEmptyBody;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @preferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesTitle;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @appearanceSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get appearanceSystem;

  /// No description provided for @appearanceLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceDark;

  /// No description provided for @hometownTitle.
  ///
  /// In en, this message translates to:
  /// **'Hometown'**
  String get hometownTitle;

  /// No description provided for @rememberLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Remember my location'**
  String get rememberLocationTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @recipesFound.
  ///
  /// In en, this message translates to:
  /// **'{count} recipes found'**
  String recipesFound(Object count);

  /// No description provided for @generatedRecipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Generated Recipes'**
  String get generatedRecipesTitle;

  /// No description provided for @newSearch.
  ///
  /// In en, this message translates to:
  /// **'New Search'**
  String get newSearch;

  /// No description provided for @noRecipesYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get noRecipesYetTitle;

  /// No description provided for @noRecipesYetBody.
  ///
  /// In en, this message translates to:
  /// **'Add ingredients or upload a photo\nto generate recipes'**
  String get noRecipesYetBody;

  /// No description provided for @startNewSearch.
  ///
  /// In en, this message translates to:
  /// **'Start New Search'**
  String get startNewSearch;

  /// No description provided for @recipeGenerationFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe generation failed'**
  String get recipeGenerationFailedTitle;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @ingredientsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredientsLabel;

  /// No description provided for @stepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get stepsLabel;

  /// No description provided for @instructionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructionsLabel;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @couldNotPickImage.
  ///
  /// In en, this message translates to:
  /// **'Could not pick image'**
  String get couldNotPickImage;

  /// No description provided for @addIngredientsOrUpload.
  ///
  /// In en, this message translates to:
  /// **'Add ingredients or upload a photo'**
  String get addIngredientsOrUpload;

  /// No description provided for @okLabel.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okLabel;

  /// No description provided for @noTrendingRecipesYet.
  ///
  /// In en, this message translates to:
  /// **'No trending recipes yet'**
  String get noTrendingRecipesYet;

  /// No description provided for @beFirstToSaveRecipe.
  ///
  /// In en, this message translates to:
  /// **'Be the first to save a recipe!'**
  String get beFirstToSaveRecipe;

  /// No description provided for @preparingKitchen.
  ///
  /// In en, this message translates to:
  /// **'Preparing your kitchen…'**
  String get preparingKitchen;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String minutesShort(Object value);

  /// No description provided for @servingsLabel.
  ///
  /// In en, this message translates to:
  /// **'{value} servings'**
  String servingsLabel(Object value);

  /// No description provided for @caloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'{value} cal'**
  String caloriesLabel(Object value);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'ja', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
