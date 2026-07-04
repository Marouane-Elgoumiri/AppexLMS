import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../../core/either.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../data/datasources/mock/mock_user_data_source.dart' show UserDataSource;

class SupabaseUserRepositoryImpl implements UserRepository {
  SupabaseUserRepositoryImpl({required this.dataSource});
  final UserDataSource dataSource;

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final model = await dataSource.getCurrent();
      return Right(model.toEntity());
    } on CacheException {
      // No signed-in session — the canonical "you must sign in" failure.
      return const Left(UnauthenticatedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserById(String id) async {
    try {
      final model = await dataSource.getById(id);
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
