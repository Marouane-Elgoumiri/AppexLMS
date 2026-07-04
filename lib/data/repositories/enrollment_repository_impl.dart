import '../../core/either.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/unit.dart';
import '../../domain/entities/enrollment.dart';
import '../../domain/repositories/enrollment_repository.dart';
import '../datasources/mock/mock_enrollment_data_source.dart';

class EnrollmentRepositoryImpl implements EnrollmentRepository {
  EnrollmentRepositoryImpl({required this.dataSource});
  final EnrollmentDataSource dataSource;

  @override
  Future<Either<Failure, List<Enrollment>>> getEnrollmentsForUser(
    String userId,
  ) async {
    try {
      final models = await dataSource.getForUser(userId);
      return Right(models.map((m) => m.toEntity()).toList(growable: false));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Enrollment>> enroll(
    String userId,
    String courseId,
  ) async {
    try {
      final model = await dataSource.enroll(userId, courseId);
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markLessonCompleted({
    required String enrollmentId,
    required String lessonId,
  }) async {
    try {
      await dataSource.markLessonCompleted(
        enrollmentId: enrollmentId,
        lessonId: lessonId,
      );
      return const Right(Unit.instance);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
