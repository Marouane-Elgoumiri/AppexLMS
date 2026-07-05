import '../../../core/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

/// Sprint 5 — wraps `UserRepository.getUserById`.
class GetUserById {
  const GetUserById(this.repository);
  final UserRepository repository;

  Future<Either<Failure, User>> call(String id) =>
      repository.getUserById(id);
}
