import '../../../core/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/enrollment.dart';
import '../../repositories/enrollment_repository.dart';

class EnrollInCourse {
  const EnrollInCourse(this.repository);
  final EnrollmentRepository repository;

  Future<Either<Failure, Enrollment>> call({
    required String userId,
    required String courseId,
  }) =>
      repository.enroll(userId, courseId);
}

class GetEnrollmentsForUser {
  const GetEnrollmentsForUser(this.repository);
  final EnrollmentRepository repository;

  Future<Either<Failure, List<Enrollment>>> call(String userId) =>
      repository.getEnrollmentsForUser(userId);
}
