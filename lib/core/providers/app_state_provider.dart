/// AppStateProvider - Single source of truth for application state.
///
/// Manages authentication status and navigation state.
/// Uses Riverpod Notifier for state management.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../debug/debug_session_log.dart';
import 'bootstrap_providers.dart';

/// Application status enum
enum AppStatus {
  loading,
  authenticated,
  unauthenticated,
}

/// Application state
class AppState {
  final AppStatus status;
  final String? errorMessage;

  const AppState({
    required this.status,
    this.errorMessage,
  });

  const AppState.loading() : status = AppStatus.loading, errorMessage = null;

  const AppState.authenticated() : status = AppStatus.authenticated, errorMessage = null;

  const AppState.unauthenticated() : status = AppStatus.unauthenticated, errorMessage = null;

  const AppState.error(this.errorMessage) : status = AppStatus.unauthenticated;

  bool get isLoading => status == AppStatus.loading;
  bool get isAuthenticated => status == AppStatus.authenticated;
  bool get isUnauthenticated => status == AppStatus.unauthenticated;
  bool get hasError => errorMessage != null;
}

/// AppStateNotifier - Manages application state.
///
/// Handles authentication state changes and navigation state.
/// Uses Riverpod Notifier for predictable state management.
class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    final bootstrap = ref.watch(bootstrapSnapshotProvider);
    if (!bootstrap.supabaseReady) {
      // #region agent log
      DebugSessionLog.log(
        location: 'app_state_provider.dart:build',
        message: 'skip supabase (not ready)',
        hypothesisId: 'H3',
      );
      // #endregion
      return const AppState.unauthenticated();
    }

    // #region agent log
    DebugSessionLog.log(
      location: 'app_state_provider.dart:build',
      message: 'reading Supabase auth',
      hypothesisId: 'H3',
    );
    // #endregion
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      return const AppState.authenticated();
    }
    return const AppState.unauthenticated();
  }

  /// Set authenticated state
  void setAuthenticated() {
    state = const AppState.authenticated();
  }

  /// Set unauthenticated state
  void setUnauthenticated() {
    state = const AppState.unauthenticated();
  }

  /// Set error state
  void setError(String message) {
    state = AppState.error(message);
  }

  /// Clear error
  void clearError() {
    if (state.isUnauthenticated) {
      state = const AppState.unauthenticated();
    }
  }
}

/// Provider for AppState
final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(
  AppStateNotifier.new,
);
