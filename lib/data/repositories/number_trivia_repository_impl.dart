import 'package:dio/dio.dart';

import '../../core/either.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/repositories/number_trivia_repository.dart';
import '../datasources/remote/number_trivia_remote_data_source.dart';

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  NumberTriviaRepositoryImpl({required this.remote});
  final NumberTriviaRemoteDataSource remote;

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumber(int number) async {
    try {
      final model = await remote.getConcreteNumber(number);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandom() async {
    try {
      final model = await remote.getRandom();
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
