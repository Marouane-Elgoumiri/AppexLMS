import '../../../core/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/course.dart';
import '../../repositories/course_repository.dart';

class GetCourseById {
  const GetCourseById(this.repository);
  final CourseRepository repository;

  Future<Either<Failure, Course>> call(String id) =>
      repository.getCourseById(id);
}
