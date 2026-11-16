/// Single initialization point: env, SharedPreferences, Supabase (best-effort).
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../debug/debug_session_log.dart';
import '../security/env_config.dart';
import 'bootstrap_snapshot.dart';

/// Legacy status enum — kept for callers that still check [BootstrapState].
enum BootstrapStatus {
  initial,
  loading,
  success,
  failure,
}

class BootstrapState {
  final BootstrapStatus status;
  final String? errorMessage;

  const BootstrapState({
    required this.status,
    this.errorMessage,
  });

  const BootstrapState.initial()
      : status = BootstrapStatus.initial,
        errorMessage = null;

  const BootstrapState.loading()
      : status = BootstrapStatus.loading,
        errorMessage = null;

  const BootstrapState.success()
      : status = BootstrapStatus.success,
        errorMessage = null;

  const BootstrapState.failure(this.errorMessage)
      : status = BootstrapStatus.failure;

  bool get isLoading => status == BootstrapStatus.loading;
  bool get isSuccess => status == BootstrapStatus.success;
  bool get isFailure => status == BootstrapStatus.failure;
}

class AppBootstrapService {
  BootstrapState _state = const BootstrapState.initial();
  BootstrapSnapshot? _snapshot;

  BootstrapState get state => _state;
  SharedPreferences? get sharedPreferences => _snapshot?.sharedPreferences;
  BootstrapSnapshot? get snapshot => _snapshot;

  void _log(String step) {
    debugPrint('[Bootstrap] $step');
  }

  /// Initializes services step-by-step. Never throws; returns [BootstrapSnapshot].
  Future<BootstrapSnapshot> initialize() async {
    _state = const BootstrapState.loading();
    final warnings = <String>[];
    var envLoaded = false;
    var supabaseReady = false;

    // 1) Environment (.env is optional — EnvConfig has fallbacks)
    try {
      _log('Loading .env');
      await dotenv.load(fileName: '.env');
      envLoaded = true;
      _log('.env loaded');
    } catch (e) {
      warnings.add('Env file not loaded ($e). Using EnvConfig fallbacks.');
      _log('WARN: $warnings.last');
      try {
        await EnvConfig.load();
        envLoaded = true;
      } catch (_) {
        envLoaded = false;
      }
    }

    // 2) SharedPreferences (required to launch UI)
    SharedPreferences? prefs;
    try {
      _log('Initializing SharedPreferences');
      prefs = await SharedPreferences.getInstance();
      _log('SharedPreferences ready');
      // #region agent log
      DebugSessionLog.log(
        location: 'app_bootstrap_service.dart:prefs',
        message: 'SharedPreferences ok',
        hypothesisId: 'H1',
      );
      // #endregion
    } catch (e, stack) {
      _log('FATAL SharedPreferences: $e\n$stack');
      _state = BootstrapState.failure('SharedPreferences failed: $e');
      return BootstrapSnapshot(
        envLoaded: envLoaded,
        supabaseReady: false,
        warnings: warnings,
        fatalError:
            'Local storage failed. Reinstall the app or clear app data.',
      );
    }

    // 3) Supabase (optional — app can show auth/offline UI without it)
    try {
      _log('Initializing Supabase');
      // #region agent log
      final supabaseStart = DateTime.now().millisecondsSinceEpoch;
      DebugSessionLog.log(
        location: 'app_bootstrap_service.dart:supabase',
        message: 'Supabase.initialize start',
        hypothesisId: 'H4',
      );
      // #endregion
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        anonKey: EnvConfig.supabaseAnonKey,
      );
      supabaseReady = true;
      _log('Supabase init done');
      // #region agent log
      DebugSessionLog.log(
        location: 'app_bootstrap_service.dart:supabase',
        message: 'Supabase.initialize end',
        hypothesisId: 'H4',
        data: {
          'ms': DateTime.now().millisecondsSinceEpoch - supabaseStart,
        },
      );
      // #endregion
    } catch (e, stack) {
      warnings.add('Supabase unavailable: $e');
      _log('WARN Supabase: $e\n$stack');
      supabaseReady = false;
    }

    // 4) Firebase (optional — no google-services.json should not crash startup)
    try {
      _log('Initializing Firebase');
      // #region agent log
      DebugSessionLog.log(
        location: 'app_bootstrap_service.dart:firebase',
        message: 'Firebase.initializeApp start',
        hypothesisId: 'H5',
      );
      // #endregion
      await Firebase.initializeApp();
      _log('Firebase ready');
      // #region agent log
      DebugSessionLog.log(
        location: 'app_bootstrap_service.dart:firebase',
        message: 'Firebase.initializeApp end',
        hypothesisId: 'H5',
      );
      // #endregion
    } catch (e) {
      warnings.add('Firebase skipped: $e');
      _log('WARN Firebase: $e');
    }

    _snapshot = BootstrapSnapshot(
      sharedPreferences: prefs,
      envLoaded: envLoaded,
      supabaseReady: supabaseReady,
      warnings: warnings,
    );
    _state = supabaseReady
        ? const BootstrapState.success()
        : BootstrapState.failure(
            warnings.isEmpty ? 'Supabase not ready' : warnings.join('\n'),
          );
    _log(
      'Bootstrap complete (supabase=$supabaseReady, warnings=${warnings.length})',
    );
    // #region agent log
    DebugSessionLog.log(
      location: 'app_bootstrap_service.dart:complete',
      message: 'bootstrap complete',
      hypothesisId: 'H1',
      data: {
        'supabaseReady': supabaseReady,
        'envLoaded': envLoaded,
        'warnings': warnings.length,
      },
    );
    // #endregion
    return _snapshot!;
  }

  @Deprecated('Use initialize() which returns BootstrapSnapshot')
  Future<BootstrapState> initializeLegacy() async {
    final snap = await initialize();
    if (!snap.canLaunchApp) {
      return BootstrapState.failure(snap.fatalError);
    }
    if (snap.supabaseReady) {
      return const BootstrapState.success();
    }
    return BootstrapState.failure(snap.warnings.join('\n'));
  }
}
