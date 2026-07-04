import '../../../core/errors/exceptions.dart';
import '../../models/course_model.dart';

abstract class CourseDataSource {
  Future<List<CourseModel>> getAll();
  Future<List<CourseModel>> getByCategory(String category);
  Future<CourseModel> getById(String id);
}

class MockCourseDataSource implements CourseDataSource {
  MockCourseDataSource() {
    _seed();
  }

  final List<CourseModel> _courses = [];

  void _seed() {
    _courses.addAll(const [
      CourseModel(
        id: 'c1',
        title: 'Flutter Foundations',
        instructor: 'Alice Johnson',
        category: 'Flutter',
        lessonCount: 12,
      ),
      CourseModel(
        id: 'c2',
        title: 'Dart for Beginners',
        instructor: 'Bob Smith',
        category: 'Dart',
        lessonCount: 10,
      ),
      CourseModel(
        id: 'c3',
        title: 'UI/UX Design Principles',
        instructor: 'Carol White',
        category: 'Design',
        lessonCount: 14,
      ),
      CourseModel(
        id: 'c4',
        title: 'State Management Deep Dive',
        instructor: 'David Lee',
        category: 'Flutter',
        lessonCount: 9,
      ),
      CourseModel(
        id: 'c5',
        title: 'Building Responsive Apps',
        instructor: 'Eva Martinez',
        category: 'Flutter',
        lessonCount: 8,
      ),
      CourseModel(
        id: 'c6',
        title: 'Backend with Dart Frog',
        instructor: 'Frank Brown',
        category: 'Backend',
        lessonCount: 16,
      ),
      CourseModel(
        id: 'c7',
        title: 'Advanced Flutter Patterns',
        instructor: 'Grace Taylor',
        category: 'Flutter',
        lessonCount: 11,
      ),
      CourseModel(
        id: 'c8',
        title: 'Clean Architecture in Dart',
        instructor: 'Henry Wilson',
        category: 'Backend',
        lessonCount: 13,
      ),
    ]);
  }

  @override
  Future<List<CourseModel>> getAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_courses);
  }

  @override
  Future<List<CourseModel>> getByCategory(String category) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (category.isEmpty) return List.unmodifiable(_courses);
    return List.unmodifiable(
      _courses.where((c) => c.category == category),
    );
  }

  @override
  Future<CourseModel> getById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final found = _courses.where((c) => c.id == id);
    if (found.isEmpty) {
      throw CacheException('Course with id "$id" not found.');
    }
    return found.first;
  }
}
