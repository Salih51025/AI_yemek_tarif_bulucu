/// Persists and resolves app theme preference.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class ThemeService {
  static const _key = 'app_theme_mode_v1';

  static ThemeMode load(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' || null => ThemeMode.system,
      _ => ThemeMode.system,
    };
  }

  static Future<void> save(SharedPreferences prefs, ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_key, value);
  }
}
