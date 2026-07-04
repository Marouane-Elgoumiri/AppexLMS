import '../../../core/either.dart';
import '../../../core/errors/failures.dart';
import '../../../core/unit.dart';
import '../entities/enrollment.dart';

abstract class EnrollmentRepository {
  Future<Either<Failure, List<Enrollment>>> getEnrollmentsForUser(String userId);
  Future<Either<Failure, Enrollment>> enroll(String userId, String courseId);
  Future<Either<Failure, Unit>> markLessonCompleted({
    required String enrollmentId,
    required String lessonId,
  });
}
