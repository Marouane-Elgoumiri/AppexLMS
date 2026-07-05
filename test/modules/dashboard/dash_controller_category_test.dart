import 'package:appex/core/either.dart';
import 'package:appex/core/errors/failures.dart';
import 'package:appex/domain/entities/course.dart';
import 'package:appex/domain/repositories/course_repository.dart';
import 'package:appex/domain/usecases/courses/get_courses.dart';
import 'package:appex/modules/dashboard/dash_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeRepo implements CourseRepository {
  _FakeRepo({this.all = const [], this.filtered = const {}, this.failCategory = false});

  final List<Course> all;
  final Map<String, List<Course>> filtered;
  final bool failCategory;

  @override
  Future<Either<Failure, List<Course>>> getAllCourses() async =>
      Right<Failure, List<Course>>(all);

  @override
  Future<Either<Failure, List<Course>>> getCoursesByCategory(String cat) async {
    if (failCategory) return const Left(ServerFailure('boom'));
    return Right<Failure, List<Course>>(filtered[cat] ?? const []);
  }

  @override
  Future<Either<Failure, Course>> getCourseById(String id) async {
    final match = all.where((c) => c.id == id).firstOrNull;
    if (match == null) return Left(NotFoundFailure('$id not found'));
    return Right<Failure, Course>(match);
  }
}

Course _course(String id, String category) => Course(
      id: id,
      title: 'Title $id',
      instructor: 'Instructor',
      category: category,
      lessonCount: 5,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    try {
      await Supabase.initialize(
        url: 'https://example.supabase.co',
        publishableKey: 'sb_publishable_testonly',
      );
    } catch (_) {/* may already be initialized */}
  });

  DashController makeCtrl(_FakeRepo repo) => DashController(
        getCourses: GetCourses(repo),
        getByCategory: GetCoursesByCategory(repo),
      );

  test('refreshDashboard with empty list → carousels empty, no error', () async {
    final ctrl = makeCtrl(_FakeRepo(all: const []));
    await ctrl.refreshDashboard();
    expect(ctrl.allCourses, isEmpty);
    expect(ctrl.popularCourses, isEmpty);
    expect(ctrl.errorMessage.value, isNull);
  });

  test('setCategory("Flutter") populates filteredCourses from repo', () async {
    final flutter = [_course('a', 'Flutter'), _course('b', 'Flutter')];
    final ctrl = makeCtrl(_FakeRepo(all: flutter, filtered: {'Flutter': flutter}));
    await ctrl.setCategory('Flutter');
    expect(ctrl.category.value, 'Flutter');
    expect(ctrl.isFilteringActive, isTrue);
    expect(ctrl.filteredCourses, hasLength(2));
    expect(ctrl.filteredCourses.first.category, 'Flutter');
    expect(ctrl.isFiltering.value, isFalse);
  });

  test('setCategory("All") clears filteredCourses', () async {
    final flutter = [_course('a', 'Flutter')];
    final ctrl = makeCtrl(_FakeRepo(all: flutter, filtered: {'Flutter': flutter}));
    await ctrl.setCategory('Flutter');
    expect(ctrl.filteredCourses, isNotEmpty);

    await ctrl.setCategory('');
    expect(ctrl.category.value, isEmpty);
    expect(ctrl.isFilteringActive, isFalse);
    expect(ctrl.filteredCourses, isEmpty);
  });

  test('setCategory failure → filterError set, filteredCourses cleared', () async {
    final ctrl = makeCtrl(_FakeRepo(all: const [], failCategory: true));
    await ctrl.setCategory('Dart');
    expect(ctrl.filterError.value, 'boom');
    expect(ctrl.filteredCourses, isEmpty);
  });

  test('refreshDashboard when category set → uses getByCategory, not getCourses',
      () async {
    final dart = [_course('a', 'Dart')];
    final flutter = [_course('b', 'Flutter')];
    final ctrl = makeCtrl(_FakeRepo(
      all: [...dart, ...flutter],
      filtered: {'Dart': dart, 'Flutter': flutter},
    ));
    await ctrl.setCategory('Dart');
    expect(ctrl.filteredCourses, hasLength(1));
    expect(ctrl.filteredCourses.first.id, 'a');
    // Carousels only refresh on 'All' — they remain whatever fresh state they had.
    expect(ctrl.allCourses, isEmpty);
  });
}
