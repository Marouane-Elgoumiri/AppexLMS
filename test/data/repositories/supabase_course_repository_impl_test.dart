import 'package:appex/core/errors/failures.dart';
import 'package:appex/core/errors/exceptions.dart';
import 'package:appex/data/datasources/mock/mock_course_data_source.dart'
    show CourseDataSource;
import 'package:appex/data/models/course_model.dart';
import 'package:appex/data/repositories/supabase/supabase_course_repository_impl.dart';
import 'package:appex/domain/repositories/course_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCourseDataSource implements CourseDataSource {
  FakeCourseDataSource({
    this.all = const [],
    this.byCategory = const [],
    this.byId,
    this.throwOnGetAll = false,
    this.throwOnGetByCategory = false,
    this.throwOnGetById = false,
  });

  List<CourseModel> all;
  List<CourseModel> byCategory;
  CourseModel? byId;
  bool throwOnGetAll;
  bool throwOnGetByCategory;
  bool throwOnGetById;

  @override
  Future<List<CourseModel>> getAll() async {
    if (throwOnGetAll) throw const ServerException('postgrest boom');
    return all;
  }

  @override
  Future<List<CourseModel>> getByCategory(String _) async {
    if (throwOnGetByCategory) throw const ServerException('postgrest boom');
    return byCategory;
  }

  @override
  Future<CourseModel> getById(String _) async {
    if (throwOnGetById) throw const CacheException('Course not found');
    return byId!;
  }
}

CourseModel _model(String id) => CourseModel(
      id: id,
      title: 'Course $id',
      instructor: 'Instructor $id',
      category: 'General',
      lessonCount: 5,
    );

void main() {
  late FakeCourseDataSource ds;
  late CourseRepository repo;

  setUp(() {
    ds = FakeCourseDataSource();
    repo = SupabaseCourseRepositoryImpl(dataSource: ds);
  });

  group('SupabaseCourseRepositoryImpl (4a.4, 4a.5)', () {
    test('getAllCourses → Right(list<Courses>) on success', () async {
      ds.all = [_model('c1'), _model('c2'), _model('c3')];

      final result = await repo.getAllCourses();

      expect(result.isRight, isTrue);
      result.fold(
        (f) => fail('expected success, got $f'),
        (list) {
          expect(list.length, 3);
          expect(list.first.id, 'c1');
          expect(list.first.title, 'Course c1');
        },
      );
    });

    test('getCoursesByCategory → Right(filtered list) on success', () async {
      ds.byCategory = [_model('c7')];

      final result = await repo.getCoursesByCategory('Flutter');

      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('expected success'),
        (list) {
          expect(list.length, 1);
          expect(list.first.id, 'c7');
        },
      );
    });

    test('getCourseById → Right(Course) on success', () async {
      ds.byId = _model('c42');

      final result = await repo.getCourseById('c42');

      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('expected success'),
        (course) {
          expect(course.id, 'c42');
          expect(course.title, 'Course c42');
        },
      );
    });

    test('ServerException path → Left(ServerFailure)', () async {
      ds.throwOnGetAll = true;

      final result = await repo.getAllCourses();

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected failure'),
      );
    });

    test('getCourseById row-miss → Left(NotFoundFailure)', () async {
      ds.throwOnGetById = true;

      final result = await repo.getCourseById('nope');

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (_) => fail('expected failure'),
      );
    });

    test('getCoursesByCategory throws → Left(ServerFailure)', () async {
      ds.throwOnGetByCategory = true;

      final result = await repo.getCoursesByCategory('Flutter');

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected failure'),
      );
    });
  });
}
