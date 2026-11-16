/// Use case for anonymous user login.
///
/// This use case encapsulates the business logic for anonymous authentication,
/// allowing users to quickly onboarding without providing credentials.
/// The anonymous session can be upgraded to a full account later.
library;


import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/base_usecase.dart';
import '../entities/auth_repository.dart';
import '../models/user_model.dart';

/// Use case for anonymous login.
///
/// Creates an anonymous user session via the repository.
/// Returns either the anonymous user or a failure.
class AnonymousLoginUseCase extends BaseUseCase<UserModel, NoParams> {
  final AuthRepository _repository;

  AnonymousLoginUseCase(this._repository);

  @override
  FutureEitherResult<UserModel> call(NoParams params) async {
    // Delegate to repository
    return await _repository.signInAnonymously();
  }
}
