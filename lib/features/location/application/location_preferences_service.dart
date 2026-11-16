/// Local persistence for hometown / region personalization.
library;

import 'package:shared_preferences/shared_preferences.dart';

abstract final class LocationPreferencesService {
  static const _rememberKey = 'remember_location_v1';
  static const _countryKey = 'saved_region_country';
  static const _cityKey = 'saved_region_city';

  static bool rememberLocation(SharedPreferences prefs) =>
      prefs.getBool(_rememberKey) ?? true;

  static Future<void> setRememberLocation(
    SharedPreferences prefs,
    bool value,
  ) async {
    await prefs.setBool(_rememberKey, value);
  }

  static String? savedCountry(SharedPreferences prefs) =>
      prefs.getString(_countryKey);

  static String? savedCity(SharedPreferences prefs) =>
      prefs.getString(_cityKey);

  static Future<void> saveRegion(
    SharedPreferences prefs, {
    required String country,
    required String city,
  }) async {
    await prefs.setString(_countryKey, country);
    await prefs.setString(_cityKey, city);
  }
}
