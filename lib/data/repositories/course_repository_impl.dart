import '../../core/either.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/mock/mock_course_data_source.dart';
import '../models/course_model.dart';

class CourseRepositoryImpl implements CourseRepository {
  CourseRepositoryImpl({required this.dataSource});
  final CourseDataSource dataSource;

  @override
  Future<Either<Failure, List<Course>>> getAllCourses() =>
      _read(() => dataSource.getAll());

  @override
  Future<Either<Failure, List<Course>>> getCoursesByCategory(String category) =>
      _read(() => dataSource.getByCategory(category));

  @override
  Future<Either<Failure, Course>> getCourseById(String id) async {
    try {
      final model = await dataSource.getById(id);
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Course>>> _read(
    Future<List<CourseModel>> Function() body,
  ) async {
    try {
      final models = await body();
      return Right(models.map((m) => m.toEntity()).toList(growable: false));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
