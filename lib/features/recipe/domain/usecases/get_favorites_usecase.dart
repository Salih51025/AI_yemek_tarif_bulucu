/// Use case for getting favorite recipes.
/// 
/// This use case encapsulates the business logic for retrieving
/// a user's favorite recipes. It validates input parameters and
/// delegates to the repository for the actual retrieval operation.
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/base_usecase.dart';
import '../entities/recipe_repository.dart';
import '../models/recipe_model.dart';

/// Parameters for the get favorites use case.
class GetFavoritesParams {
  final String userId;
  final int page;
  final int limit;

  GetFavoritesParams({
    required this.userId,
    this.page = 1,
    this.limit = 20,
  });
}

/// Use case for getting favorite recipes.
/// 
/// Validates user ID and pagination parameters, then retrieves
/// favorite recipes via the repository.
/// Returns either a list of recipes or a failure.
class GetFavoritesUseCase extends BaseUseCase<List<RecipeModel>, GetFavoritesParams> {
  final RecipeRepository _repository;

  GetFavoritesUseCase(this._repository);

  @override
  FutureEitherResult<List<RecipeModel>> call(GetFavoritesParams params) async {
    // Validate user ID
    if (params.userId.isEmpty) {
      return const Left(
        DataParsingFailure(
          message: 'User ID is required',
          code: 'user_id_required',
        ),
      );
    }

    // Validate page number
    if (params.page < 1) {
      return const Left(
        DataParsingFailure(
          message: 'Page number must be greater than 0',
          code: 'invalid_page',
        ),
      );
    }

    // Validate limit
    if (params.limit < 1 || params.limit > 100) {
      return const Left(
        DataParsingFailure(
          message: 'Limit must be between 1 and 100',
          code: 'invalid_limit',
        ),
      );
    }

    // Delegate to repository
    return await _repository.getFavoriteRecipes(
      userId: params.userId,
      page: params.page,
      limit: params.limit,
    );
  }
}
