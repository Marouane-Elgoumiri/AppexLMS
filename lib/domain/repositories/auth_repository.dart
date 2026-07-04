import '../../core/either.dart';
import '../../core/errors/failures.dart';
import '../../core/unit.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String displayName,
  });
  Future<Either<Failure, Unit>> logout();
}
