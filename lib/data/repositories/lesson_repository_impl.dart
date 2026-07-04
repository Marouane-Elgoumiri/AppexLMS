import '../../core/either.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../datasources/mock/mock_lesson_data_source.dart';

class LessonRepositoryImpl implements LessonRepository {
  LessonRepositoryImpl({required this.dataSource});
  final LessonDataSource dataSource;

  @override
  Future<Either<Failure, List<Lesson>>> getLessonsForCourse(
    String courseId,
  ) async {
    try {
      final models = await dataSource.getForCourse(courseId);
      return Right(models.map((m) => m.toEntity()).toList(growable: false));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
