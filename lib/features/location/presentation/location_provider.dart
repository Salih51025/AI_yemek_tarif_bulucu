library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers/auth_providers.dart';
import '../application/location_preferences_service.dart';

class LocationPrefsState {
  const LocationPrefsState({
    this.rememberLocation = true,
    this.savedCountry,
    this.savedCity,
  });

  final bool rememberLocation;
  final String? savedCountry;
  final String? savedCity;

  LocationPrefsState copyWith({
    bool? rememberLocation,
    String? savedCountry,
    String? savedCity,
  }) =>
      LocationPrefsState(
        rememberLocation: rememberLocation ?? this.rememberLocation,
        savedCountry: savedCountry ?? this.savedCountry,
        savedCity: savedCity ?? this.savedCity,
      );
}

final locationPrefsProvider =
    NotifierProvider<LocationPrefsNotifier, LocationPrefsState>(
  LocationPrefsNotifier.new,
);

class LocationPrefsNotifier extends Notifier<LocationPrefsState> {
  @override
  LocationPrefsState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return LocationPrefsState(
      rememberLocation: LocationPreferencesService.rememberLocation(prefs),
      savedCountry: LocationPreferencesService.savedCountry(prefs),
      savedCity: LocationPreferencesService.savedCity(prefs),
    );
  }

  Future<void> setRememberLocation(bool value) async {
    state = state.copyWith(rememberLocation: value);
    await LocationPreferencesService.setRememberLocation(
      ref.read(sharedPreferencesProvider),
      value,
    );
  }

  Future<void> saveRegion({
    required String country,
    required String city,
  }) async {
    state = state.copyWith(savedCountry: country, savedCity: city);
    if (!state.rememberLocation) return;
    await LocationPreferencesService.saveRegion(
      ref.read(sharedPreferencesProvider),
      country: country,
      city: city,
    );
  }
}
