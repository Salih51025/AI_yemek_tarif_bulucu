// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'AI Chef';

  @override
  String get navGenerate => '作成';

  @override
  String get navTrending => 'トレンド';

  @override
  String get navSaved => '保存済み';

  @override
  String get navProfile => 'プロフィール';

  @override
  String get generateTitle => 'AIで作成';

  @override
  String get generateHero => 'ある材料を教えてください。\nあなたが好きなレシピを作ります。';

  @override
  String get ingredientPhotoTitle => '材料の写真';

  @override
  String get tapToAddPhoto => 'タップして写真を追加';

  @override
  String get ingredientsCardTitle => 'キッチンに何がありますか？';

  @override
  String get ingredientsCardSubtitle => '材料を追加するか、上で写真を撮ってください';

  @override
  String get ingredientHint => '例：トマト、鶏肉…';

  @override
  String get noIngredientsYet => '材料がまだありません';

  @override
  String get generateButton => 'レシピを生成';

  @override
  String get scanButton => 'スキャン';

  @override
  String get shareButton => '共有';

  @override
  String get saveButton => '保存';

  @override
  String get savedButton => '保存済み';

  @override
  String get aiCookingTitle => 'AI Chef が調理中';

  @override
  String get aiThinking1 => '材料を分析しています…';

  @override
  String get aiThinking2 => '最適なレシピを探しています…';

  @override
  String get aiThinking3 => 'あなた向けにレシピを作成しています…';

  @override
  String get aiThinking4 => 'もうすぐ完了…';

  @override
  String get favoritesTitle => '保存したレシピ';

  @override
  String get favoritesEmptyTitle => '保存したレシピがありません';

  @override
  String get favoritesEmptyBody => '閲覧中にハートを押すと、ここにすぐ表示されます。';

  @override
  String get profileTitle => 'プロフィール';

  @override
  String get preferencesTitle => '設定';

  @override
  String get appearanceTitle => '外観';

  @override
  String get appearanceSystem => 'システム';

  @override
  String get appearanceLight => 'ライト';

  @override
  String get appearanceDark => 'ダーク';

  @override
  String get hometownTitle => '地域';

  @override
  String get rememberLocationTitle => '場所を記憶する';

  @override
  String get languageTitle => '言語';

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
    return '$count件のレシピが見つかりました';
  }

  @override
  String get generatedRecipesTitle => '生成されたレシピ';

  @override
  String get newSearch => '新規検索';

  @override
  String get noRecipesYetTitle => 'レシピがまだありません';

  @override
  String get noRecipesYetBody => '材料を追加するか写真をアップロードしてレシピを生成してください';

  @override
  String get startNewSearch => '新しい検索を開始';

  @override
  String get recipeGenerationFailedTitle => 'レシピ生成に失敗しました';

  @override
  String get tryAgain => '再試行';

  @override
  String get retry => '再実行';

  @override
  String get ingredientsLabel => '材料';

  @override
  String get stepsLabel => '手順';

  @override
  String get instructionsLabel => '作り方';

  @override
  String get showMore => 'もっと見る';

  @override
  String get showLess => '閉じる';

  @override
  String get couldNotPickImage => '画像を選択できませんでした';

  @override
  String get addIngredientsOrUpload => '材料を追加するか写真をアップロードしてください';

  @override
  String get okLabel => 'OK';

  @override
  String get noTrendingRecipesYet => 'トレンドレシピはまだありません';

  @override
  String get beFirstToSaveRecipe => '最初にレシピを保存しましょう！';

  @override
  String get preparingKitchen => 'キッチンを準備しています…';

  @override
  String minutesShort(Object value) {
    return '$value分';
  }

  @override
  String servingsLabel(Object value) {
    return '$value人前';
  }

  @override
  String caloriesLabel(Object value) {
    return '$value kcal';
  }
}
