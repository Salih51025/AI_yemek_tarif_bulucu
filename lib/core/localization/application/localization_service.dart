/// Local persistence for locale selection.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class LocalizationService {
  static const _key = 'app_locale_v1';

  static Locale? load(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split('_');
    if (parts.isEmpty) return null;
    if (parts.length == 1) return Locale(parts[0]);
    return Locale(parts[0], parts[1]);
  }

  static Future<void> save(SharedPreferences prefs, Locale? locale) async {
    if (locale == null) {
      await prefs.remove(_key);
      return;
    }
    final raw =
        locale.countryCode == null ? locale.languageCode : '${locale.languageCode}_${locale.countryCode}';
    await prefs.setString(_key, raw);
  }
}

