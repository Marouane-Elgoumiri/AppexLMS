import 'package:appex/core/errors/exceptions.dart';
import 'package:appex/core/errors/failures.dart';
import 'package:appex/data/datasources/mock/mock_lesson_data_source.dart'
    show LessonDataSource;
import 'package:appex/data/models/lesson_model.dart';
import 'package:appex/data/repositories/supabase/supabase_lesson_repository_impl.dart';
import 'package:appex/domain/repositories/lesson_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeLessonDataSource implements LessonDataSource {
  FakeLessonDataSource({
    this.lessons = const [],
    this.throwOnFetch = false,
  });

  List<LessonModel> lessons;
  bool throwOnFetch;

  @override
  Future<List<LessonModel>> getForCourse(String _) async {
    if (throwOnFetch) throw const ServerException('boom');
    return lessons;
  }
}

LessonModel _l(String id, int order) => LessonModel(
      id: id,
      courseId: 'c1',
      title: 'Lesson $id',
      order: order,
      durationSeconds: 300,
    );

void main() {
  late FakeLessonDataSource ds;
  late LessonRepository repo;

  setUp(() {
    ds = FakeLessonDataSource();
    repo = SupabaseLessonRepositoryImpl(dataSource: ds);
  });

  group('SupabaseLessonRepositoryImpl', () {
    test('getLessonsForCourse → Right(List<Lesson>) on success', () async {
      ds.lessons = [_l('l1', 1), _l('l2', 2), _l('l3', 3)];

      final result = await repo.getLessonsForCourse('c1');

      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('expected success'),
        (list) {
          expect(list.length, 3);
          expect(list[0].order, 1);
          expect(list[2].order, 3);
        },
      );
    });

    test('ServerException path → Left(ServerFailure)', () async {
      ds.throwOnFetch = true;

      final result = await repo.getLessonsForCourse('c1');

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected failure'),
      );
    });

    test('Empty list → Right([]) (no failure)', () async {
      ds.lessons = const [];

      final result = await repo.getLessonsForCourse('c1');

      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('expected success'),
        (list) => expect(list, isEmpty),
      );
    });
  });
}
