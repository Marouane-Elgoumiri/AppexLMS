import '../../core/either.dart';
import '../../core/errors/failures.dart';
import '../entities/lesson.dart';

abstract class LessonRepository {
  Future<Either<Failure, List<Lesson>>> getLessonsForCourse(String courseId);
}
