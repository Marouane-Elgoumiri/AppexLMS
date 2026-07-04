import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/either.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/lesson.dart';
import '../../../domain/repositories/lesson_repository.dart';
import '../../../data/datasources/mock/mock_lesson_data_source.dart' show LessonDataSource;

class SupabaseLessonRepositoryImpl implements LessonRepository {
  SupabaseLessonRepositoryImpl({required this.dataSource});
  final LessonDataSource dataSource;

  @override
  Future<Either<Failure, List<Lesson>>> getLessonsForCourse(
    String courseId,
  ) async {
    try {
      final models = await dataSource.getForCourse(courseId);
      return Right(models.map((m) => m.toEntity()).toList(growable: false));
    } on CacheException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
