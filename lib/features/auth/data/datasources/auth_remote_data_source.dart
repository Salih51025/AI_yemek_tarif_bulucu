/// Remote data source for authentication operations using Supabase.
///
/// This class handles all authentication-related network operations
/// with Supabase, including sign in, sign up, anonymous authentication,
/// and sign out. It maps Supabase-specific errors to application exceptions.
library;

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/errors/exceptions.dart';
import '../../domain/models/user_model.dart';

/// Remote data source for authentication.
///
/// Provides methods for user authentication operations using Supabase Auth.
/// All methods throw [AppException] on failure to allow the repository
/// layer to convert them to [Failure] objects.
class AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AuthRemoteDataSource(this._supabaseClient);

  /// Signs in a user with email and password.
  ///
  /// [email] - User's email address
  /// [password] - User's password
  ///
  /// Returns the authenticated user data.
  ///
  /// Throws [AuthException] if authentication fails.
  /// Throws [NetworkException] if network error occurs.
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException(
          message: 'Sign in failed: No user returned',
          code: 'no_user',
        );
      }

      return UserModel.fromSupabaseUser(user);
    } on AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AuthException(
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      throw NetworkException(message: 'Network error during sign in: $e');
    }
  }

  /// Registers a new user with email and password.
  ///
  /// [email] - User's email address
  /// [password] - User's password (must be at least 6 characters)
  /// [displayName] - Optional display name for the user
  ///
  /// Returns the newly created user data.
  ///
  /// Throws [AuthException] if registration fails.
  /// Throws [NetworkException] if network error occurs.
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException(
          message: 'Sign up failed: No user returned',
          code: 'no_user',
        );
      }

      return UserModel.fromSupabaseUser(user);
    } on AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AuthException(
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      throw NetworkException(message: 'Network error during sign up: $e');
    }
  }

  /// Signs in anonymously for quick onboarding.
  ///
  /// Creates an anonymous user session that can be upgraded later.
  ///
  /// Returns the anonymous user data.
  ///
  /// Throws [AuthException] if anonymous sign in fails.
  /// Throws [NetworkException] if network error occurs.
  Future<UserModel> signInAnonymously() async {
    try {
      final response = await _supabaseClient.auth.signInAnonymously();

      final user = response.user;
      if (user == null) {
        throw const AuthException(
          message: 'Anonymous sign in failed: No user returned',
          code: 'no_user',
        );
      }

      return UserModel.fromSupabaseUser(user);
    } on AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AuthException(
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      throw NetworkException(
          message: 'Network error during anonymous sign in: $e');
    }
  }

  /// Signs out the current user.
  ///
  /// Clears the current session and signs out the user.
  ///
  /// Throws [AuthException] if sign out fails.
  /// Throws [NetworkException] if network error occurs.
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } on AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AuthException(
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      throw NetworkException(message: 'Network error during sign out: $e');
    }
  }

  /// Stream of authentication state changes.
  ///
  /// Emits a new [AuthState] whenever the authentication state changes.
  /// This can be used to react to sign in/sign out events.
  ///
  /// Returns a Stream of AuthState objects.
  Stream<AuthState> get authStateChanges {
    return _supabaseClient.auth.onAuthStateChange;
  }

  /// Gets the current authenticated user.
  ///
  /// Returns the current user if authenticated, null otherwise.
  ///
  /// Throws [NetworkException] if fetching user fails.
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    } catch (e) {
      throw NetworkException(
          message: 'Network error fetching current user: $e');
    }
  }
}
