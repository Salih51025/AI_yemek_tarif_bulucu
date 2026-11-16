/// Custom exception classes for handling application-specific errors.
///
/// These exceptions represent failure scenarios in the data layer
/// and are used to propagate error information through the architecture.
library;

/// Base exception class for all custom exceptions.
///
/// Provides a consistent structure for error handling with
/// a message and optional stack trace.
abstract class AppException implements Exception {
  /// Human-readable error message
  final String message;

  /// Optional error code for programmatic handling
  final String? code;

  /// Optional stack trace for debugging
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when network operations fail.
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Exception thrown when authentication fails.
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Exception thrown when server returns an error response.
class ServerException extends AppException {
  /// HTTP status code
  final int? statusCode;

  const ServerException({
    required super.message,
    this.statusCode,
    super.code,
    super.stackTrace,
  });
}

/// Exception thrown when data parsing or validation fails.
class DataParsingException extends AppException {
  const DataParsingException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Exception thrown when cache operations fail.
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Exception thrown when file operations fail.
class FileSystemException extends AppException {
  const FileSystemException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}
