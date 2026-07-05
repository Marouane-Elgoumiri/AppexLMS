import '../../../core/either.dart';
import '../../../core/errors/failures.dart';
import '../../../core/unit.dart';
import '../../repositories/enrollment_repository.dart';

/// Sprint 5 — wraps `EnrollmentRepository.markLessonCompleted` so the use
/// case layer is one step above the repo interface for Course Detail's
/// progress tracking flow.
class MarkLessonCompleted {
  const MarkLessonCompleted(this.repository);
  final EnrollmentRepository repository;

  Future<Either<Failure, Unit>> call({
    required String enrollmentId,
    required String lessonId,
  }) =>
      repository.markLessonCompleted(
        enrollmentId: enrollmentId,
        lessonId: lessonId,
      );
}
