import 'package:appex/data/models/enrollment_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EnrollmentModel', () {
    test('fromJson with completed lesson ids (3.4)', () {
      final model = EnrollmentModel.fromJson(<String, dynamic>{
        'id': 7,
        'user_id': 1,
        'course_id': 2,
        'enrolled_at': '2026-04-01T12:00:00Z',
        'completed_lesson_ids': [3, 4, 5],
      });

      expect(model.id, '7');
      expect(model.userId, '1');
      expect(model.courseId, '2');
      expect(model.enrolledAt.toIso8601String(), '2026-04-01T12:00:00.000Z');
      expect(model.completedLessonIds, ['3', '4', '5']);
    });

    test('round-trips through toJson and parses back identically', () {
      final original = EnrollmentModel.fromJson(<String, dynamic>{
        'id': 7,
        'user_id': 1,
        'course_id': 2,
        'enrolled_at': '2026-04-01T12:00:00Z',
        'completed_lesson_ids': [3, 4, 5],
      });
      final json = original.toJson();
      final rehydrated = EnrollmentModel.fromJson(json);

      expect(rehydrated.id, original.id);
      expect(rehydrated.userId, original.userId);
      expect(rehydrated.courseId, original.courseId);
      expect(rehydrated.enrolledAt, original.enrolledAt);
      expect(rehydrated.completedLessonIds, original.completedLessonIds);
    });
  });
}
