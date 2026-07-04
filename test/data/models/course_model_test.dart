import 'package:appex/data/models/course_model.dart';
import 'package:appex/domain/entities/course.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CourseModel', () {
    final json = <String, dynamic>{
      'id': 1,
      'title': 'Flutter Foundations',
      'instructor': 'Alice Johnson',
      'category': 'Flutter',
      'lesson_count': 12,
      'image_url': 'https://example.com/c.png',
    };

    test('fromJson produces a populated model (3.2)', () {
      final model = CourseModel.fromJson(json);

      expect(model.id, '1');
      expect(model.title, 'Flutter Foundations');
      expect(model.instructor, 'Alice Johnson');
      expect(model.category, 'Flutter');
      expect(model.lessonCount, 12);
      expect(model.imageUrl, 'https://example.com/c.png');
    });

    test('round-trips through toJson', () {
      final model = CourseModel.fromJson(json);
      final reserialized = model.toJson();

      expect(reserialized['id'], '1');
      expect(reserialized['title'], 'Flutter Foundations');
      expect(reserialized['lesson_count'], 12);
      expect(reserialized['image_url'], 'https://example.com/c.png');
    });

    test('toEntity yields a Course with the same field values', () {
      final model = CourseModel.fromJson(json);
      final entity = model.toEntity();

      expect(entity, isA<Course>());
      expect(entity.title, 'Flutter Foundations');
      expect(entity.lessonCount, 12);
    });

    test('tolerates missing optional fields', () {
      final minimal = <String, dynamic>{
        'id': 'abc',
        'title': 'T',
        'instructor': 'I',
        'lesson_count': 0,
      };
      final model = CourseModel.fromJson(minimal);
      expect(model.category, 'General');
      expect(model.imageUrl, null);
    });
  });
}
