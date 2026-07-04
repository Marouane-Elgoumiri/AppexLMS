import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/either.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/repositories/course_repository.dart';
import '../../../data/datasources/mock/mock_course_data_source.dart' show CourseDataSource;
import '../../../data/models/course_model.dart';

/// Supabase-backed implementation of [CourseRepository].
///
/// Translates the data source's `ServerException` (network/Postgrest failure)
/// and `CacheException` (row miss) into typed [Failure]s:
///   ServerException    -> ServerFailure
///   CacheException     -> NotFoundFailure  (single-row reads)
///   PostgrestException -> ServerFailure
class SupabaseCourseRepositoryImpl implements CourseRepository {
  SupabaseCourseRepositoryImpl({required this.dataSource});
  final CourseDataSource dataSource;

  @override
  Future<Either<Failure, List<Course>>> getAllCourses() =>
      _readList(() => dataSource.getAll());

  @override
  Future<Either<Failure, List<Course>>> getCoursesByCategory(
    String category,
  ) =>
      _readList(() => dataSource.getByCategory(category));

  @override
  Future<Either<Failure, Course>> getCourseById(String id) async {
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

  Future<Either<Failure, List<Course>>> _readList(
    Future<List<CourseModel>> Function() body,
  ) async {
    try {
      final models = await body();
      return Right(models.map((m) => m.toEntity()).toList(growable: false));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
