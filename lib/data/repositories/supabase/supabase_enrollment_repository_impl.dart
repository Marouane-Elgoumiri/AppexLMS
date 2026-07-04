import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/either.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../../core/unit.dart';
import '../../../domain/entities/enrollment.dart';
import '../../../domain/repositories/enrollment_repository.dart';
import '../../../data/datasources/mock/mock_enrollment_data_source.dart' show EnrollmentDataSource;

class SupabaseEnrollmentRepositoryImpl implements EnrollmentRepository {
  SupabaseEnrollmentRepositoryImpl({required this.dataSource});
  final EnrollmentDataSource dataSource;

  @override
  Future<Either<Failure, List<Enrollment>>> getEnrollmentsForUser(
    String userId,
  ) async {
    try {
      final models = await dataSource.getForUser(userId);
      return Right(models.map((m) => m.toEntity()).toList(growable: false));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
