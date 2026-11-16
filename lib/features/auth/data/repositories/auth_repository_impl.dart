/// Implementation of the authentication repository.
///
/// This repository coordinates authentication operations between
/// the data source and the domain layer, converting exceptions
/// to failures for consistent error handling across the application.
library;

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/security/token_manager.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../domain/entities/auth_repository.dart';
import '../../domain/models/user_model.dart';

/// Implementation of the authentication repository.
///
/// This class implements the [AuthRepository] interface and handles
/// all authentication operations by delegating to the remote data source.
/// It converts data layer exceptions to domain layer failures.
class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenManager _tokenManager;
  final SupabaseClient _supabaseClient;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenManager tokenManager,
    required SupabaseClient supabaseClient,
  })  : _remoteDataSource = remoteDataSource,
        _tokenManager = tokenManager,
        _supabaseClient = supabaseClient;

  @override
  Future<bool> get hasNetworkConnection async {
    // In a production app, this would check actual network connectivity
    // using connectivity_plus or similar package
    return true;
  }

  @override
  Future<void> clearCache() async {
    await _tokenManager.clearTokens();
  }

  @override
  FutureEitherResult<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store tokens for session management
      final session = _supabaseClient.auth.currentSession;
      if (session != null) {
        await _tokenManager.setAccessToken(session.accessToken);
        await _tokenManager.setRefreshToken(session.refreshToken ?? '');
        await _tokenManager.setUserId(user.id);
        await _tokenManager.setSessionExpiry(session.expiresAt != null
            ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
            : DateTime.now().add(const Duration(hours: 24)));
      }

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  FutureEitherResult<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final user = await _remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      // Store tokens for session management
      final session = _supabaseClient.auth.currentSession;
      if (session != null) {
        await _tokenManager.setAccessToken(session.accessToken);
        await _tokenManager.setRefreshToken(session.refreshToken ?? '');
        await _tokenManager.setUserId(user.id);
        await _tokenManager.setSessionExpiry(session.expiresAt != null
            ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
            : DateTime.now().add(const Duration(hours: 24)));
      }

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  FutureEitherResult<UserModel> signInAnonymously() async {
    try {
      final user = await _remoteDataSource.signInAnonymously();

      // Store tokens for session management
      final session = _supabaseClient.auth.currentSession;
      if (session != null) {
        await _tokenManager.setAccessToken(session.accessToken);
        await _tokenManager.setRefreshToken(session.refreshToken ?? '');
        await _tokenManager.setUserId(user.id);
        await _tokenManager.setSessionExpiry(session.expiresAt != null
            ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
            : DateTime.now().add(const Duration(hours: 24)));
      }

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  FutureEitherResult<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
      await _tokenManager.clearTokens();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Stream<AuthState> get authStateChanges {
    return _remoteDataSource.authStateChanges;
  }

  @override
  FutureEitherResult<UserModel?> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unexpected error: $e'));
    }
  }
}
