/// Global Riverpod provider for Supabase client initialization.
///
/// This provider manages the Supabase client instance and provides
/// it throughout the application using Riverpod's dependency injection.
/// The client is initialized in main.dart before the app starts.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'bootstrap_providers.dart';

/// Provider for the Supabase client instance.
///
/// This provider provides access to the globally initialized Supabase client.
/// Initialization is handled in main.dart before the app starts.
/// Configuration is sourced from EnvConfig with runtime fallbacks.
///
/// Usage:
/// ```dart
/// final supabase = ref.watch(supabaseClientProvider);
/// final user = supabase.auth.currentUser;
/// ```
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  final bootstrap = ref.watch(bootstrapSnapshotProvider);
  if (!bootstrap.supabaseReady) {
    throw StateError(
      'Supabase is not initialized. Check bootstrap / network and retry.',
    );
  }
  return Supabase.instance.client;
});
