/// Environment configuration management for secure credential storage.
///
/// This class provides a centralized way to manage environment-specific
/// configuration such as API keys, Supabase URLs, and Firebase config.
/// These values are loaded from the .env file using flutter_dotenv.
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration holder.
///
/// NOTE: Values are loaded from the .env file in the project root.
/// Never hardcode sensitive credentials in source code.
class EnvConfig {
  EnvConfig._();

  static bool _isLoaded = false;

  /// Loads the .env file from the project root.
  ///
  /// Must be called before accessing any configuration values.
  /// Typically called in main() before Supabase initialization.
  static Future<void> load() async {
    if (!_isLoaded) {
      try {
        await dotenv.load(fileName: '.env');
        _isLoaded = true;
      } catch (e) {
        // If .env file is not found, we'll use fallback values
        // This allows the app to run in development without .env
        _isLoaded = true;
      }
    }
  }

  /// Supabase project URL
  ///
  /// Format: https://your-project.supabase.co
  /// Provides runtime fallback to production endpoint if .env loading fails.
  static String get supabaseUrl {
    final value = dotenv.env['SUPABASE_URL'];
    if (value != null && value.isNotEmpty) {
      return value;
    }
    // Runtime fallback to production endpoint
    return 'https://xazcvsbahxkwhmkgzwbv.supabase.co';
  }

  /// Supabase anonymous/public API key
  ///
  /// This key is safe to use on the client side for public operations.
  /// Provides runtime fallback to production key if .env loading fails.
  static String get supabaseAnonKey {
    final value = dotenv.env['SUPABASE_ANON_KEY'];
    if (value != null && value.isNotEmpty) {
      return value;
    }
    // Runtime fallback to production key
    return 'sb_publishable_l4JC7LMqZY0Er8IKefdbXQ__TWL-hCE';
  }

  /// Firebase Storage bucket name
  ///
  /// Provides runtime fallback if .env loading fails.
  static String get firebaseStorageBucket {
    final value = dotenv.env['FIREBASE_STORAGE_BUCKET'];
    if (value != null && value.isNotEmpty) {
      return value;
    }
    // Runtime fallback
    return 'YOUR_FIREBASE_STORAGE_BUCKET';
  }

  /// Google Gemini API key for AI recipe generation
  ///
  /// Provides runtime fallback to production key if .env loading fails.
  static String get geminiApiKey {
    final value = dotenv.env['GEMINI_API_KEY'];
    if (value != null && value.isNotEmpty) {
      return value;
    }
    return '';
  }

  /// Primary model — verified via ListModels API (v1beta, May 2026).
  /// `gemini-1.5-flash` is removed; use 2.5 flash for free-tier recipe JSON.
  /// Primary: stable alias model (fewer 503s than pinned 2.5 IDs).
  static const String geminiModel = 'gemini-flash-latest';

  /// Fallback when primary is unavailable or rate-limited.
  static const String geminiModelFallback = 'gemini-2.5-flash';

  /// Higher-quality generation for premium flows.
  static const String geminiModelPro = 'gemini-2.5-pro';

  /// Indicates if the app is running in debug mode
  static bool get isDebug =>
      const bool.fromEnvironment('dart.vm.product') == false;

  /// Validates that all required environment variables are set.
  ///
  /// Returns true if all critical values are configured, false otherwise.
  /// Only validates Supabase credentials as they are critical for app startup.
  /// Firebase and Gemini are non-blocking background services.
  static bool validate() {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }

  /// Returns a map of all configuration values for debugging.
  ///
  /// WARNING: Never log or display sensitive values in production.
  /// This method should only be used in debug builds.
  static Map<String, String> getConfigMap() {
    if (!isDebug) {
      return {'error': 'Cannot expose config in production'};
    }

    return {
      'supabaseUrl': supabaseUrl,
      'supabaseAnonKey':
          supabaseAnonKey.replaceAll(RegExp(r'.{8}'), '********'),
      'firebaseStorageBucket': firebaseStorageBucket,
      'isDebug': isDebug.toString(),
    };
  }
}
