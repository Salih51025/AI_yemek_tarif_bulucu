// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'AI Chef';

  @override
  String get navGenerate => 'Üret';

  @override
  String get navTrending => 'Trend';

  @override
  String get navSaved => 'Kayıtlı';

  @override
  String get navProfile => 'Profil';

  @override
  String get generateTitle => 'Yapay Zekâ ile Oluştur';

  @override
  String get generateHero =>
      'Elindeki malzemeleri yaz.\nSana seveceğin tarifler hazırlayalım.';

  @override
  String get ingredientPhotoTitle => 'Malzeme fotoğrafı';

  @override
  String get tapToAddPhoto => 'Fotoğraf eklemek için dokun';

  @override
  String get ingredientsCardTitle => 'Mutfakta neler var?';

  @override
  String get ingredientsCardSubtitle =>
      'Malzemeleri ekle veya yukarıdan fotoğraf çek';

  @override
  String get ingredientHint => 'ör. domates, tavuk…';

  @override
  String get noIngredientsYet => 'Henüz malzeme yok';

  @override
  String get generateButton => 'Tarif Oluştur';

  @override
  String get scanButton => 'Tara';

  @override
  String get shareButton => 'Paylaş';

  @override
  String get saveButton => 'Kaydet';

  @override
  String get savedButton => 'Kaydedildi';

  @override
  String get aiCookingTitle => 'AI Chef pişiriyor';

  @override
  String get aiThinking1 => 'Malzemeler analiz ediliyor…';

  @override
  String get aiThinking2 => 'En iyi tarifler aranıyor…';

  @override
  String get aiThinking3 => 'Kişisel tarifler hazırlanıyor…';

  @override
  String get aiThinking4 => 'Neredeyse hazır…';

  @override
  String get favoritesTitle => 'Kayıtlı Tarifler';

  @override
  String get favoritesEmptyTitle => 'Henüz kayıtlı tarif yok';

  @override
  String get favoritesEmptyBody =>
      'Gezinirken kalbe bas — tarif burada hemen görünsün.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get preferencesTitle => 'Tercihler';

  @override
  String get appearanceTitle => 'Görünüm';

  @override
  String get appearanceSystem => 'Sistem';

  @override
  String get appearanceLight => 'Açık';

  @override
  String get appearanceDark => 'Koyu';

  @override
  String get hometownTitle => 'Bölge';

  @override
  String get rememberLocationTitle => 'Konumumu hatırla';

  @override
  String get languageTitle => 'Dil';

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
    return '$count tarif bulundu';
  }

  @override
  String get generatedRecipesTitle => 'Oluşturulan Tarifler';

  @override
  String get newSearch => 'Yeni Arama';

  @override
  String get noRecipesYetTitle => 'Henüz tarif yok';

  @override
  String get noRecipesYetBody =>
      'Tarif oluşturmak için malzeme ekle veya fotoğraf yükle';

  @override
  String get startNewSearch => 'Yeni Aramaya Başla';

  @override
  String get recipeGenerationFailedTitle => 'Tarif oluşturma başarısız';

  @override
  String get tryAgain => 'Tekrar Dene';

  @override
  String get retry => 'Yeniden Dene';

  @override
  String get ingredientsLabel => 'Malzemeler';

  @override
  String get stepsLabel => 'Adımlar';

  @override
  String get instructionsLabel => 'Talimatlar';

  @override
  String get showMore => 'Daha Fazla';

  @override
  String get showLess => 'Daha Az';

  @override
  String get couldNotPickImage => 'Görsel seçilemedi';

  @override
  String get addIngredientsOrUpload => 'Malzeme ekleyin veya fotoğraf yükleyin';

  @override
  String get okLabel => 'Tamam';

  @override
  String get noTrendingRecipesYet => 'Henüz trend tarif yok';

  @override
  String get beFirstToSaveRecipe => 'İlk kaydeden siz olun!';

  @override
  String get preparingKitchen => 'Mutfağın hazırlanıyor…';

  @override
  String minutesShort(Object value) {
    return '$value dk';
  }

  @override
  String servingsLabel(Object value) {
    return '$value porsiyon';
  }

  @override
  String caloriesLabel(Object value) {
    return '$value kalori';
  }
}
