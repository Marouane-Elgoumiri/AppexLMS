import '../../core/either.dart';
import '../../core/errors/failures.dart';
import '../entities/course.dart';

abstract class CourseRepository {
  Future<Either<Failure, List<Course>>> getAllCourses();
  Future<Either<Failure, List<Course>>> getCoursesByCategory(String category);
  Future<Either<Failure, Course>> getCourseById(String id);
}
