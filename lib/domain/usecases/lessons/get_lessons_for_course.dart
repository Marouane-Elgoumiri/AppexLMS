import '../../../core/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/lesson.dart';
import '../../repositories/lesson_repository.dart';

class GetLessonsForCourse {
  const GetLessonsForCourse(this.repository);
  final LessonRepository repository;

  Future<Either<Failure, List<Lesson>>> call(String courseId) =>
      repository.getLessonsForCourse(courseId);
}
