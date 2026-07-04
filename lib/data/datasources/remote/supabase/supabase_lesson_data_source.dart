import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../models/lesson_model.dart';
import '../../mock/mock_lesson_data_source.dart' show LessonDataSource;

/// Supabase-backed implementation of [LessonDataSource].
class SupabaseLessonDataSource implements LessonDataSource {
  SupabaseLessonDataSource({required this.client});
  final SupabaseClient client;

  static const _table = 'lessons';

  @override
  Future<List<LessonModel>> getForCourse(String courseId) async {
    try {
      final rows = await client
          .from(_table)
          .select()
          .eq('course_id', courseId)
          .order('"order"', ascending: true);
      if (rows.isEmpty) {
        throw CacheException('No lessons found for course "$courseId".');
      }
      return rows
          .map((r) => LessonModel.fromJson(Map<String, dynamic>.from(r)))
          .toList(growable: false);
    } catch (e) {
      throw e is CacheException
          ? e
          : ServerException(e.toString());
    }
  }
}
