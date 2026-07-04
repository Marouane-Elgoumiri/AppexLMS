import '../../../core/errors/exceptions.dart';
import '../../../core/unit.dart';
import '../../models/enrollment_model.dart';

abstract class EnrollmentDataSource {
  Future<List<EnrollmentModel>> getForUser(String userId);
  Future<EnrollmentModel> enroll(String userId, String courseId);
  Future<Unit> markLessonCompleted({
    required String enrollmentId,
    required String lessonId,
  });
}

class InMemoryEnrollmentDataSource implements EnrollmentDataSource {
  final List<EnrollmentModel> _store = [];
  int _idCounter = 0;

  @override
  Future<List<EnrollmentModel>> getForUser(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _store.where((e) => e.userId == userId).toList(growable: false);
  }

  @override
  Future<EnrollmentModel> enroll(String userId, String courseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final existing = _store.where(
      (e) => e.userId == userId && e.courseId == courseId,
    );
    if (existing.isNotEmpty) return existing.first;

    _idCounter++;
    final created = EnrollmentModel(
      id: 'enr_$_idCounter',
      userId: userId,
      courseId: courseId,
      enrolledAt: DateTime.now().toUtc(),
      completedLessonIds: const [],
    );
    _store.add(created);
    return created;
  }

  @override
  Future<Unit> markLessonCompleted({
    required String enrollmentId,
    required String lessonId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final idx = _store.indexWhere((e) => e.id == enrollmentId);
    if (idx < 0) {
      throw CacheException('Enrollment "$enrollmentId" not found.');
    }
    final current = _store[idx];
    if (current.completedLessonIds.contains(lessonId)) {
      return Unit.instance;
    }
    _store[idx] = EnrollmentModel(
      id: current.id,
      userId: current.userId,
      courseId: current.courseId,
      enrolledAt: current.enrolledAt,
      completedLessonIds: [...current.completedLessonIds, lessonId],
    );
    return Unit.instance;
  }
}
