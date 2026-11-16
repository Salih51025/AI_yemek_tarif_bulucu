/// Repository interface for authentication operations.
/// 
/// This abstract class defines the contract for authentication
/// operations that must be implemented by the data layer.
/// It follows Clean Architecture principles by defining the
/// interface in the domain layer.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/repositories/base_repository.dart';
import '../models/user_model.dart';

/// Repository interface for authentication operations.
/// 
/// Defines the contract for all authentication-related operations
/// including sign in, sign up, anonymous authentication, and sign out.
/// All methods return [EitherResult] for consistent error handling.
abstract class AuthRepository extends BaseRepository {
  /// Signs in a user with email and password.
  /// 
  /// [email] - User's email address
  /// [password] - User's password
  /// 
  /// Returns [EitherResult] containing either the authenticated user or a [Failure].
  FutureEitherResult<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Registers a new user with email and password.
  /// 
  /// [email] - User's email address
  /// [password] - User's password (must be at least 6 characters)
  /// [displayName] - Optional display name for the user
  /// 
  /// Returns [EitherResult] containing either the newly created user or a [Failure].
  FutureEitherResult<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Signs in anonymously for quick onboarding.
  /// 
  /// Creates an anonymous user session that can be upgraded later.
  /// 
  /// Returns [EitherResult] containing either the anonymous user or a [Failure].
  FutureEitherResult<UserModel> signInAnonymously();

  /// Signs out the current user.
  /// 
  /// Clears the current session and signs out the user.
  /// 
  /// Returns [EitherResult] containing either Unit (success) or a [Failure].
  FutureEitherResult<void> signOut();

  /// Stream of authentication state changes.
  /// 
  /// Emits a new [AuthState] whenever the authentication state changes.
  Stream<AuthState> get authStateChanges;

  /// Gets the current authenticated user.
  /// 
  /// Returns [EitherResult] containing either the current user or null if not authenticated.
  FutureEitherResult<UserModel?> getCurrentUser();
}
