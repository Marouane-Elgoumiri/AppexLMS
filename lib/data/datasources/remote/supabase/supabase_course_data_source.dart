import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../models/course_model.dart';
import '../../mock/mock_course_data_source.dart' show CourseDataSource;

/// Supabase-backed implementation of [CourseDataSource].
///
/// Mirrors the in-memory mock's surface; reads from the `public.courses`
/// table. Throws [ServerException] on any Postgrest failure; throws
/// `CacheException` (via the repository mapping) when a single-row read
/// misses.
class SupabaseCourseDataSource implements CourseDataSource {
  SupabaseCourseDataSource({required this.client});
  final SupabaseClient client;

  static const _table = 'courses';

  @override
  Future<List<CourseModel>> getAll() async {
    try {
      final rows = await client.from(_table).select();
      return _rowsToModels(rows);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<CourseModel>> getByCategory(String category) async {
    try {
      final query = client.from(_table).select();
      final rows = category.isEmpty
          ? await query
          : await query.eq('category', category);
      return _rowsToModels(rows);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CourseModel> getById(String id) async {
    try {
      final rows = await client
          .from(_table)
          .select()
          .eq('id', id)
          .limit(1);
      if (rows.isEmpty) {
        throw CacheException('Course with id "$id" not found.');
      }
      return CourseModel.fromJson(rows.first);
    } catch (e) {
      throw e is CacheException
          ? e
          : ServerException(e.toString());
    }
  }

  List<CourseModel> _rowsToModels(List<Map<String, dynamic>> rows) {
    return rows
        .map((r) => CourseModel.fromJson(Map<String, dynamic>.from(r)))
        .toList(growable: false);
  }
}
