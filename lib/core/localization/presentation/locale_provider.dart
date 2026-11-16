library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/presentation/providers/auth_providers.dart';
import '../../debug/session_debug_log.dart';
import '../application/localization_service.dart';

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final loaded = LocalizationService.load(prefs);

    // #region agent log
    SessionDebugLog.log(
      location: 'locale_provider.dart:build',
      message: 'locale loaded',
      hypothesisId: 'L1',
      data: {'locale': loaded?.toLanguageTag()},
      runId: 'locale-pre',
    );
    // #endregion

    return loaded;
  }

  Future<void> setLocale(Locale? locale) async {
    if (state?.toLanguageTag() == locale?.toLanguageTag()) return;
    state = locale;
    await LocalizationService.save(ref.read(sharedPreferencesProvider), locale);

    // #region agent log
    SessionDebugLog.log(
      location: 'locale_provider.dart:setLocale',
      message: 'locale saved',
      hypothesisId: 'L2',
      data: {'locale': locale?.toLanguageTag()},
      runId: 'locale-pre',
    );
    // #endregion
  }
}

// Supported locales (single source of truth).
const supportedLocales = <Locale>[
  Locale('en'),
  Locale('tr'),
  Locale('de'),
  Locale('ja'),
];

