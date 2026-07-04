import '../../../core/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/course.dart';
import '../../repositories/course_repository.dart';

class GetCourses {
  const GetCourses(this.repository);
  final CourseRepository repository;

  Future<Either<Failure, List<Course>>> call() => repository.getAllCourses();
}

class GetCoursesByCategory {
  const GetCoursesByCategory(this.repository);
  final CourseRepository repository;

  Future<Either<Failure, List<Course>>> call(String category) =>
      repository.getCoursesByCategory(category);
}
