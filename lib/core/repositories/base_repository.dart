/// Base repository interface for all data repositories.
/// 
/// This abstract class defines the contract that all repositories
/// must follow, ensuring consistency across the data layer.
/// Repositories are responsible for coordinating data operations
/// between data sources (remote, local, cache) and the domain layer.
library;

import '../errors/failures.dart';

/// Base repository interface.
/// 
/// All feature-specific repositories should extend this interface
/// to maintain consistency across the data layer. This interface
/// doesn't define specific methods but serves as a marker for
/// repository classes and can be extended with common functionality.
/// 
/// Example usage:
/// ```dart
/// class AuthRepository extends BaseRepository {
///   // Implementation
/// }
/// ```
abstract class BaseRepository {
  /// Checks if the repository has an active network connection.
  /// 
  /// Returns true if network is available, false otherwise.
  /// This can be used to determine whether to make remote calls
  /// or fall back to cached data.
  Future<bool> get hasNetworkConnection;

  /// Clears all cached data for this repository.
  /// 
  /// Should be called when logging out or when data needs to be refreshed.
  /// Implementations should handle cache invalidation appropriately.
  Future<void> clearCache();
}

/// Base repository with CRUD operations.
/// 
/// Extends BaseRepository with common CRUD (Create, Read, Update, Delete)
/// operations that most repositories will need. This provides a consistent
/// interface for data manipulation across different features.
/// 
/// Type parameter [T] represents the entity type this repository manages.
/// Type parameter [ID] represents the identifier type (typically String or int).
abstract class CrudRepository<T, ID> extends BaseRepository {
  /// Retrieves an entity by its identifier.
  /// 
  /// Returns [EitherResult] containing either the entity or a [Failure].
  /// Implementations should check local cache first, then remote source.
  FutureEitherResult<T> getById(ID id);

  /// Retrieves all entities.
  /// 
  /// Returns [EitherResult] containing either a list of entities or a [Failure].
  /// Implementations should support pagination for large datasets.
  FutureEitherResult<List<T>> getAll({
    int page = 1,
    int limit = 20,
  });

  /// Creates a new entity.
  /// 
  /// Returns [EitherResult] containing either the created entity or a [Failure].
  /// The created entity should include any server-generated fields (e.g., ID).
  FutureEitherResult<T> create(T entity);

  /// Updates an existing entity.
  /// 
  /// Returns [EitherResult] containing either the updated entity or a [Failure].
  /// Implementations should handle optimistic updates and rollback on failure.
  FutureEitherResult<T> update(T entity);

  /// Deletes an entity by its identifier.
  /// 
  /// Returns [EitherResult] containing either Unit (success) or a [Failure].
  /// Implementations should handle soft deletes if required by the business logic.
  FutureEitherResult<void> delete(ID id);
}
