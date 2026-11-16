/// Failure classes for representing error states in the domain layer.
///
/// These classes follow the Either pattern from Dartz, allowing
/// the domain layer to return either a success result or a failure.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

/// Base failure class for all domain layer failures.
///
/// Failures are used to represent error states that can be
/// handled by the presentation layer without exposing implementation details.
abstract class Failure extends Equatable {
  /// Human-readable error message
  final String message;

  /// Optional error code for programmatic handling
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Failure representing network connectivity issues.
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
  });
}

/// Failure representing authentication errors.
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });
}

/// Failure representing server-side errors.
class ServerFailure extends Failure {
  /// HTTP status code
  final int? statusCode;

  const ServerFailure({
    required super.message,
    this.statusCode,
    super.code,
  });

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Failure representing data parsing or validation errors.
class DataParsingFailure extends Failure {
  const DataParsingFailure({
    required super.message,
    super.code,
  });
}

/// Failure representing cache operation errors.
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });
}

/// Failure representing file system errors.
class FileSystemFailure extends Failure {
  const FileSystemFailure({
    required super.message,
    super.code,
  });
}

/// Failure representing unknown or unexpected errors.
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.code,
  });
}

/// Type alias for Either pattern with Failure as the left type.
typedef EitherResult<T> = Either<Failure, T>;

/// Type alias for Future Either pattern.
typedef FutureEitherResult<T> = Future<Either<Failure, T>>;
