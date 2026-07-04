import '../../core/either.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/unit.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/mock/mock_user_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.userDataSource});
  final MockUserDataSource userDataSource;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = await userDataSource.authenticate(
        email: email,
        password: password,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final model = await userDataSource.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await userDataSource.logout();
      return const Right(Unit.instance);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
