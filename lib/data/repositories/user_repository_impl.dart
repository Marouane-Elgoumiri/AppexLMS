import '../../core/either.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/mock/mock_user_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({required this.dataSource});
  final UserDataSource dataSource;

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final model = await dataSource.getCurrent();
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserById(String id) async {
    try {
      final model = await dataSource.getById(id);
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
