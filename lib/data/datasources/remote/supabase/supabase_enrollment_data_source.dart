import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/unit.dart';
import '../../../models/enrollment_model.dart';
import '../../mock/mock_enrollment_data_source.dart' show EnrollmentDataSource;

/// Supabase-backed implementation of [EnrollmentDataSource].
///
/// `enroll()` is idempotent — the table has a UNIQUE(user_id, course_id)
/// constraint, so a conflict suppresses the second insert and we return
/// the existing row.
class SupabaseEnrollmentDataSource implements EnrollmentDataSource {
  SupabaseEnrollmentDataSource({required this.client});
  final SupabaseClient client;

  static const _table = 'enrollments';

  @override
  Future<List<EnrollmentModel>> getForUser(String userId) async {
    try {
      final rows = await client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('enrolled_at', ascending: false);
      return rows
          .map((r) => EnrollmentModel.fromJson(Map<String, dynamic>.from(r)))
          .toList(growable: false);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<EnrollmentModel> enroll(String userId, String courseId) async {
    try {
      // Idempotency: try to find an existing row first.
      final existing = await client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .eq('course_id', courseId)
          .limit(1);
      if (existing.isNotEmpty) {
        return EnrollmentModel.fromJson(
          Map<String, dynamic>.from(existing.first),
        );
      }

      final inserted = await client
          .from(_table)
          .insert({
            'user_id': userId,
            'course_id': courseId,
          })
          .select()
          .limit(1);
      if (inserted.isEmpty) {
        throw const ServerException('Enrollment insert returned no row.');
      }
      return EnrollmentModel.fromJson(
        Map<String, dynamic>.from(inserted.first),
      );
    } catch (e) {
      throw e is ServerException
          ? e
          : ServerException(e.toString());
    }
  }

  @override
  Future<Unit> markLessonCompleted({
    required String enrollmentId,
    required String lessonId,
  }) async {
    try {
      // Postgres SQL: UPDATE enrollments
      //               SET completed_lesson_ids =
      //                 array_append(coalesce(completed_lesson_ids, '{}'::text[]), $2)
      //               WHERE id = $1 AND NOT ($2 = ANY(completed_lesson_ids));
      //
      // We issue this through `rpc()` is awkward; instead we use the
      // PostgREST `.rpc()` interface with a tiny inline helper function.
      final result = await client.rpc(
        'mark_lesson_completed',
        params: {
          'p_enrollment_id': enrollmentId,
          'p_lesson_id': lessonId,
        },
      );
      // result may be null or a status map. Not throwing == success.
      // ignore: unused_local_variable
      final _ = result;
      return Unit.instance;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
