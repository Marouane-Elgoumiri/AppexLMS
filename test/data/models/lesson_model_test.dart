import 'package:appex/data/models/lesson_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LessonModel', () {
    test('fromJson produces a populated model (3.3)', () {
      final model = LessonModel.fromJson(<String, dynamic>{
        'id': 1,
        'course_id': 9,
        'title': 'Widgets 101',
        'order': 1,
        'duration_seconds': 480,
      });

      expect(model.id, '1');
      expect(model.courseId, '9');
      expect(model.title, 'Widgets 101');
      expect(model.order, 1);
      expect(model.durationSeconds, 480);
    });

    test('round-trips through toJson', () {
      final model = LessonModel.fromJson(<String, dynamic>{
        'id': 1,
        'course_id': 9,
        'title': 'Widgets 101',
        'order': 1,
        'duration_seconds': 480,
      });
      final json = model.toJson();
      expect(json['id'], '1');
      expect(json['course_id'], '9');
      expect(json['duration_seconds'], 480);
    });
  });
}
