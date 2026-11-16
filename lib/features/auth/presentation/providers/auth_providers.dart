/// Riverpod providers for authentication feature.
///
/// This file provides all the dependency injection for the authentication
/// feature including data sources, repositories, and use cases.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/security/token_manager.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_repository.dart';
import '../../domain/usecases/anonymous_login_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

/// Provider for SharedPreferences.
///
/// Lazy initialization of SharedPreferences.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized before use');
});

/// Provider for TokenManager.
///
/// Creates and provides a singleton TokenManager instance.
/// Uses Provider with lazy initialization for SharedPreferences.
final tokenManagerProvider = Provider<TokenManager>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return TokenManager(prefs);
});

/// Provider for AuthRemoteDataSource.
///
/// Creates and provides the AuthRemoteDataSource with SupabaseClient.
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final supabaseClient = ref.read(supabaseClientProvider);
  return AuthRemoteDataSource(supabaseClient);
});

/// Provider for AuthRepository.
///
/// Creates and provides the AuthRepository implementation with all dependencies.
/// Uses Provider (not FutureProvider) to avoid dependency chains.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.read(authRemoteDataSourceProvider);
  final supabaseClient = ref.read(supabaseClientProvider);
  final tokenManager = ref.read(tokenManagerProvider);

  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    tokenManager: tokenManager,
    supabaseClient: supabaseClient,
  );
});

/// Provider for LoginUseCase.
///
/// Creates and provides the LoginUseCase with AuthRepository.
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return LoginUseCase(repository);
});

/// Provider for RegisterUseCase.
///
/// Creates and provides the RegisterUseCase with AuthRepository.
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return RegisterUseCase(repository);
});

/// Provider for AnonymousLoginUseCase.
///
/// Creates and provides the AnonymousLoginUseCase with AuthRepository.
final anonymousLoginUseCaseProvider = Provider<AnonymousLoginUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return AnonymousLoginUseCase(repository);
});
