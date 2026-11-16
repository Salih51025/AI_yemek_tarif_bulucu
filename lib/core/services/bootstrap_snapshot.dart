/// Immutable result of [AppBootstrapService.initialize].
library;

import 'package:shared_preferences/shared_preferences.dart';

/// What succeeded during startup and what can be used safely.
class BootstrapSnapshot {
  const BootstrapSnapshot({
    this.sharedPreferences,
    required this.envLoaded,
    required this.supabaseReady,
    this.warnings = const [],
    this.fatalError,
  });

  final SharedPreferences? sharedPreferences;
  final bool envLoaded;
  final bool supabaseReady;
  final List<String> warnings;
  final String? fatalError;

  bool get hasFatalError => fatalError != null;

  /// Minimum bar: local prefs available so theme/locale/auth cache can load.
  bool get canLaunchApp => sharedPreferences != null && !hasFatalError;

  bool get isFullyReady => canLaunchApp && supabaseReady && envLoaded;
}
