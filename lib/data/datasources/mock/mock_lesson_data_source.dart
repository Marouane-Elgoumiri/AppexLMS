import '../../../core/errors/exceptions.dart';
import '../../models/lesson_model.dart';

abstract class LessonDataSource {
  Future<List<LessonModel>> getForCourse(String courseId);
}

class MockLessonDataSource implements LessonDataSource {
  MockLessonDataSource() {
    _seed();
  }

  final List<LessonModel> _lessons = [];

  void _seed({int defaultCount = 5}) {
    for (var courseIndex = 1; courseIndex <= 8; courseIndex++) {
      final courseId = 'c$courseIndex';
      for (var i = 1; i <= defaultCount; i++) {
        _lessons.add(
          LessonModel(
            id: 'l_${courseId}_$i',
            courseId: courseId,
            title: 'Lesson $i — $courseId',
            order: i,
            durationSeconds: 300 + i * 60,
          ),
        );
      }
    }
  }

  @override
  Future<List<LessonModel>> getForCourse(String courseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final filtered = _lessons.where((l) => l.courseId == courseId).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    if (filtered.isEmpty) {
      throw CacheException('No lessons found for course "$courseId".');
    }
    return filtered;
  }
}
