import '../../../core/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

/// Sprint 5 — wraps `UserRepository.getCurrentUser`. Used by Profile to
/// re-fetch the active user (independent of AuthSession's cached value).
class GetCurrentUser {
  const GetCurrentUser(this.repository);
  final UserRepository repository;

  Future<Either<Failure, User>> call() => repository.getCurrentUser();
}
