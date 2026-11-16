/// Base use case interface for domain layer business logic.
///
/// This abstract class defines the contract for use cases (interactors)
/// that encapsulate business logic. Use cases are the entry point for
/// the presentation layer to interact with the domain layer.
///
/// Following Clean Architecture principles, use cases should:
/// - Contain business logic only
/// - Be independent of frameworks (Flutter, Riverpod, etc.)
/// - Return domain entities or value objects
/// - Handle errors via the Either pattern
library;

import '../errors/failures.dart';

/// Base use case interface.
///
/// All use cases should extend this interface to maintain consistency.
/// Use cases are typically single-purpose classes that perform one
/// specific business operation.
///
/// Type parameter [Type] represents the return type of the use case.
/// Type parameter [Params] represents the input parameters type.
///
/// Example usage:
/// ```dart
/// class GetRecipeById extends BaseUseCase<Recipe, String> {
///   @override
///   FutureEitherResult<Recipe> call(String params) {
///     // Implementation
///   }
/// }
/// ```
abstract class BaseUseCase<Type, Params> {
  /// Executes the use case with the provided parameters.
  ///
  /// [params] are the input parameters for the use case.
  /// If the use case doesn't require parameters, use [NoParams].
  ///
  /// Returns [EitherResult] containing either the result or a [Failure].
  FutureEitherResult<Type> call(Params params);
}

/// Marker class for use cases that don't require parameters.
///
/// Use this when a use case doesn't need any input parameters.
///
/// Example usage:
/// ```dart
/// class GetCurrentUser extends BaseUseCase<User, NoParams> {
///   @override
///   FutureEitherResult<User> call(NoParams params) {
///     // Implementation
///   }
/// }
/// ```
class NoParams {
  /// Singleton instance for convenience.
  static final instance = NoParams._();

  /// Factory constructor for creating NoParams instances.
  factory NoParams() => instance;

  NoParams._();
}
