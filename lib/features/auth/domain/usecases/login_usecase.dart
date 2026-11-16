/// Use case for user login with email and password.
///
/// This use case encapsulates the business logic for user authentication
/// via email and password. It validates input parameters and delegates
/// to the repository for the actual authentication operation.
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/base_usecase.dart';
import '../entities/auth_repository.dart';
import '../models/user_model.dart';

/// Parameters for the login use case.
class LoginParams {
  final String email;
  final String password;

  LoginParams({
    required this.email,
    required this.password,
  });
}

/// Use case for user login.
///
/// Validates email and password parameters and authenticates the user
/// via the repository. Returns either the authenticated user or a failure.
class LoginUseCase extends BaseUseCase<UserModel, LoginParams> {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  @override
  FutureEitherResult<UserModel> call(LoginParams params) async {
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

    // Delegate to repository
    return await _repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}
