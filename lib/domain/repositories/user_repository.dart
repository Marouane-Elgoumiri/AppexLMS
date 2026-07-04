import '../../core/either.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, User>> getUserById(String id);
}
