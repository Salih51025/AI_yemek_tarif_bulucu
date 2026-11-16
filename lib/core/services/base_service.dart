/// Base service interface for external service integrations.
/// 
/// This abstract class defines the contract for services that interact
/// with external APIs, third-party services, or edge functions.
/// Services are responsible for making HTTP requests, handling responses,
/// and converting them to domain entities or DTOs.
library;

import '../errors/failures.dart';

/// Base service interface.
/// 
/// All service implementations should extend this interface to maintain
/// consistency across the service layer. Services are typically used by
/// repositories to communicate with external systems.
/// 
/// Example usage:
/// ```dart
/// class RecipeGenerationService extends BaseService {
///   FutureEitherResult<Recipe> generateRecipe(Ingredients input) {
///     // Implementation
///   }
/// }
/// ```
abstract class BaseService {
  /// Executes a service operation with error handling.
  /// 
  /// This is a helper method that wraps service operations in a
  /// try-catch block and converts exceptions to [Failure] objects.
  /// Implementations can use this to standardize error handling.
  /// 
  /// Returns [EitherResult] containing either the result or a [Failure].
  FutureEitherResult<T> executeOperation<T>(Future<T> Function() operation);
}

/// Base HTTP service for making API requests.
/// 
/// Extends BaseService with HTTP-specific functionality for making
/// REST API calls. This provides a consistent interface for all
/// HTTP-based service implementations.
/// 
/// Type parameter [T] represents the response type.
abstract class HttpService extends BaseService {
  /// Performs a GET request to the specified endpoint.
  /// 
  /// [path] is the API endpoint path (relative to base URL).
  /// [queryParameters] are optional query parameters.
  /// 
  /// Returns [EitherResult] containing either the response or a [Failure].
  FutureEitherResult<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  });

  /// Performs a POST request to the specified endpoint.
  /// 
  /// [path] is the API endpoint path (relative to base URL).
  /// [data] is the request body (typically a Map or JSON-serializable object).
  /// [queryParameters] are optional query parameters.
  /// 
  /// Returns [EitherResult] containing either the response or a [Failure].
  FutureEitherResult<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  });

  /// Performs a PUT request to the specified endpoint.
  /// 
  /// [path] is the API endpoint path (relative to base URL).
  /// [data] is the request body (typically a Map or JSON-serializable object).
  /// [queryParameters] are optional query parameters.
  /// 
  /// Returns [EitherResult] containing either the response or a [Failure].
  FutureEitherResult<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  });

  /// Performs a DELETE request to the specified endpoint.
  /// 
  /// [path] is the API endpoint path (relative to base URL).
  /// [queryParameters] are optional query parameters.
  /// 
  /// Returns [EitherResult] containing either the response or a [Failure].
  FutureEitherResult<T> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  });
}
