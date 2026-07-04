import 'package:appex/core/errors/exceptions.dart';
import 'package:appex/core/errors/failures.dart';
import 'package:appex/core/unit.dart';
import 'package:appex/data/datasources/mock/mock_enrollment_data_source.dart'
    show EnrollmentDataSource;
import 'package:appex/data/models/enrollment_model.dart';
import 'package:appex/data/repositories/supabase/supabase_enrollment_repository_impl.dart';
import 'package:appex/domain/repositories/enrollment_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeEnrollmentDataSource implements EnrollmentDataSource {
  FakeEnrollmentDataSource({
    this.forUser = const [],
    this.enrollResult,
    this.throwOnEnroll = false,
    this.throwOnUpdate = false,
    this.updateSucceeds = true,
    String? expectedEnrollUser,
    String? expectedEnrollCourse,
  });

  List<EnrollmentModel> forUser;
  EnrollmentModel? enrollResult;
  bool throwOnEnroll;
  bool throwOnUpdate;
  bool updateSucceeds;
  String? expectedEnrollUser;
  String? expectedEnrollCourse;

  // capture for assertions
  String? lastEnrollUser;
  String? lastEnrollCourse;
  String? lastEnrollmentId;
  String? lastLessonId;

  @override
  Future<List<EnrollmentModel>> getForUser(String userId) async {
    if (userId == 'throwing') throw const ServerException('boom');
    return forUser;
  }

  @override
  Future<EnrollmentModel> enroll(String userId, String courseId) async {
    lastEnrollUser = userId;
    lastEnrollCourse = courseId;
    if (throwOnEnroll) throw const ServerException('conflict');
    return enrollResult!;
  }

  @override
  Future<Unit> markLessonCompleted({
    required String enrollmentId,
    required String lessonId,
  }) async {
    lastEnrollmentId = enrollmentId;
    lastLessonId = lessonId;
    if (throwOnUpdate) throw const ServerException('boom');
    if (!updateSucceeds) throw const ServerException('boom');
    return Unit.instance;
  }
}

EnrollmentModel _e(String id) => EnrollmentModel(
      id: id,
      userId: 'u1',
      courseId: 'c1',
      enrolledAt: DateTime.utc(2026, 1, 1),
      completedLessonIds: const ['l1'],
    );

void main() {
  late FakeEnrollmentDataSource ds;
  late EnrollmentRepository repo;

  setUp(() {
    ds = FakeEnrollmentDataSource();
    repo = SupabaseEnrollmentRepositoryImpl(dataSource: ds);
  });

  group('SupabaseEnrollmentRepositoryImpl (4a.6, 4a.7)', () {
    test('getEnrollmentsForUser → Right(List<Enrollment>) on success', () async {
      ds.forUser = [_e('enr1'), _e('enr2')];

      final result = await repo.getEnrollmentsForUser('u1');

      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('expected success'),
        (list) {
          expect(list.length, 2);
          expect(list[0].id, 'enr1');
          expect(list[1].completedLessonIds.first, 'l1');
        },
      );
    });

    test('enroll → Right(Enrollment) and delgates user+course ids', () async {
      ds.enrollResult = _e('enr-new');

      final result = await repo.enroll('u1', 'c_flutter');

      expect(result.isRight, isTrue);
      expect(ds.lastEnrollUser, 'u1');
      expect(ds.lastEnrollCourse, 'c_flutter');
      result.fold(
        (_) => fail('expected success'),
        (e) => expect(e.id, 'enr-new'),
      );
    });

    test('enroll ServerException → Left(ServerFailure)', () async {
      ds.throwOnEnroll = true;

      final result = await repo.enroll('u1', 'c1');

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected failure'),
      );
    });

    test('markLessonCompleted → Right(Unit) on success', () async {
      final result = await repo.markLessonCompleted(
        enrollmentId: 'enr1',
        lessonId: 'l_new',
      );

      expect(result.isRight, isTrue);
      expect(ds.lastEnrollmentId, 'enr1');
      expect(ds.lastLessonId, 'l_new');
    });

    test('markLessonCompleted ServerException → Left(ServerFailure)', () async {
      ds.throwOnUpdate = true;

      final result = await repo.markLessonCompleted(
        enrollmentId: 'enr1',
        lessonId: 'l1',
      );

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected failure'),
      );
    });
  });
}
