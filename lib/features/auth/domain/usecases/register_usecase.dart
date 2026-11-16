/// Use case for user registration with email and password.
///
/// This use case encapsulates the business logic for user registration.
/// It validates input parameters and delegates to the repository for
/// the actual registration operation.
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/base_usecase.dart';
import '../entities/auth_repository.dart';
import '../models/user_model.dart';

/// Parameters for the register use case.
class RegisterParams {
  final String email;
  final String password;
  final String? displayName;

  RegisterParams({
    required this.email,
    required this.password,
    this.displayName,
  });
}

/// Use case for user registration.
///
/// Validates email, password, and optional display name parameters,
/// then registers the user via the repository. Returns either the
/// newly created user or a failure.
class RegisterUseCase extends BaseUseCase<UserModel, RegisterParams> {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  @override
  FutureEitherResult<UserModel> call(RegisterParams params) async {
    // Validate email
    if (params.email.isEmpty) {
      return const Left(
        AuthFailure(message: 'Email is required', code: 'email_required'),
      );
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(params.email)) {
      return const Left(
        AuthFailure(message: 'Invalid email format', code: 'invalid_email'),
      );
    }

    // Validate password
    if (params.password.isEmpty) {
      return const Left(
        AuthFailure(message: 'Password is required', code: 'password_required'),
      );
    }

    // Validate password length
    if (params.password.length < 6) {
      return const Left(
        AuthFailure(
          message: 'Password must be at least 6 characters',
          code: 'password_too_short',
        ),
      );
    }

    // Validate display name if provided
    if (params.displayName != null && params.displayName!.isEmpty) {
      return const Left(
        AuthFailure(
          message: 'Display name cannot be empty',
          code: 'invalid_display_name',
        ),
      );
    }

    // Delegate to repository
    return await _repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}
