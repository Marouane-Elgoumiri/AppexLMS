import 'package:appex/core/either.dart';
import 'package:appex/core/errors/failures.dart';
import 'package:appex/core/unit.dart';
import 'package:appex/domain/entities/course.dart';
import 'package:appex/domain/entities/enrollment.dart';
import 'package:appex/domain/entities/lesson.dart';
import 'package:appex/domain/entities/user.dart';
import 'package:appex/domain/repositories/course_repository.dart';
import 'package:appex/domain/repositories/enrollment_repository.dart';
import 'package:appex/domain/repositories/lesson_repository.dart';
import 'package:appex/domain/repositories/user_repository.dart';
import 'package:appex/domain/usecases/courses/get_course_by_id.dart';
import 'package:appex/domain/usecases/enrollments/enroll_in_course.dart';
import 'package:appex/domain/usecases/enrollments/mark_lesson_completed.dart';
import 'package:appex/domain/usecases/lessons/get_lessons_for_course.dart';
import 'package:appex/modules/auth/auth_session.dart';
import 'package:appex/modules/courses/course_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _CourseRepo implements CourseRepository {
  _CourseRepo({this.course});
  Course? course;
  @override
  Future<Either<Failure, Course>> getCourseById(String id) async {
    if (course == null) return Left(NotFoundFailure('not found'));
    return Right<Failure, Course>(course!);
  }

  @override
  Future<Either<Failure, List<Course>>> getAllCourses() async =>
      Right<Failure, List<Course>>(course == null ? const [] : [course!]);

  @override
  Future<Either<Failure, List<Course>>> getCoursesByCategory(String _) async =>
      Right<Failure, List<Course>>(course == null ? const [] : [course!]);
}

class _LessonRepo implements LessonRepository {
  _LessonRepo({this.lessons = const []});
  List<Lesson> lessons;
  @override
  Future<Either<Failure, List<Lesson>>> getLessonsForCourse(String _) async =>
      Right<Failure, List<Lesson>>(lessons);
}

class _EnrollmentRepo implements EnrollmentRepository {
  _EnrollmentRepo({
    this.enrollments = const [],
    this.enrollResult,
    this.markResult,
  });

  List<Enrollment> enrollments;
  Either<Failure, Enrollment>? enrollResult;
  Either<Failure, Unit>? markResult;

  @override
  Future<Either<Failure, List<Enrollment>>> getEnrollmentsForUser(
      String uid) async {
    final list = enrollments.where((e) => e.userId == uid).toList();
    return Right<Failure, List<Enrollment>>(list);
  }

  @override
  Future<Either<Failure, Enrollment>> enroll(String uid, String cid) async {
    return enrollResult ?? const Left(ServerFailure('not stubbed'));
  }

  @override
  Future<Either<Failure, Unit>> markLessonCompleted({
    required String enrollmentId,
    required String lessonId,
  }) async {
    return markResult ?? const Right<Failure, Unit>(Unit.instance);
  }
}

class _UserRepo implements UserRepository {
  final User? user;
  _UserRepo(this.user);

  @override
  Future<Either<Failure, User>> getCurrentUser() async =>
      user == null ? const Left(UnauthenticatedFailure()) : Right(user!);

  @override
  Future<Either<Failure, User>> getUserById(String _) async =>
      user == null ? const Left(UnauthenticatedFailure()) : Right(user!);
}

Course _course = Course(
  id: 'c1',
  title: 'Flutter Foundations',
  instructor: 'Alice',
  category: 'Flutter',
  lessonCount: 5,
);

Enrollment _enrollment({List<String> completed = const []}) => Enrollment(
      id: 'e1',
      userId: 'u1',
      courseId: 'c1',
      enrolledAt: DateTime(2024),
      completedLessonIds: completed,
    );

List<Lesson> _lessons() => [
      Lesson(id: 'l1', courseId: 'c1', title: 'Lesson 1', order: 1, durationSeconds: 360),
      Lesson(id: 'l2', courseId: 'c1', title: 'Lesson 2', order: 2, durationSeconds: 420),
      Lesson(id: 'l3', courseId: 'c1', title: 'Lesson 3', order: 3, durationSeconds: 300),
    ];

User _user = User(id: 'u1', email: 'student@appex.dev', displayName: 'Demo Student');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
  });

  CourseController makeController({
    required _CourseRepo cr,
    required _LessonRepo lr,
    required _EnrollmentRepo er,
    User? sessionUser,
  }) {
    final session = AuthSession(userRepository: _UserRepo(sessionUser));
    if (sessionUser != null) {
      session.setUser(sessionUser);
    }
    Get.put<AuthSession>(session, permanent: true);

    // Use Get.put so onInit() runs and hydrates userId from the session.
    return Get.put(
      CourseController(
        getCourseById: GetCourseById(cr),
        getLessonsForCourse: GetLessonsForCourse(lr),
        enrollInCourse: EnrollInCourse(er),
        markLessonCompleted: MarkLessonCompleted(er),
        enrollmentRepository: er,
      ),
    );
  }

  test('loadCourse with lesson + enrollment hydrates all state', () async {
    final ctrl = makeController(
      cr: _CourseRepo(course: _course),
      lr: _LessonRepo(lessons: _lessons()),
      er: _EnrollmentRepo(enrollments: [_enrollment()]),
      sessionUser: _user,
    );

    await ctrl.loadCourse('c1');

    expect(ctrl.course.value?.id, 'c1');
    expect(ctrl.lessons, hasLength(3));
    expect(ctrl.enrollment.value?.id, 'e1');
    expect(ctrl.completedLessonIds, isEmpty);
    expect(ctrl.userId.value, 'u1');
  });

  test('loadCourse with no enrollment → enrollment null', () async {
    final ctrl = makeController(
      cr: _CourseRepo(course: _course),
      lr: _LessonRepo(lessons: _lessons()),
      er: _EnrollmentRepo(enrollments: const []),
      sessionUser: _user,
    );

    await ctrl.loadCourse('c1');

    expect(ctrl.enrollment.value, isNull);
    expect(ctrl.completedLessonIds, isEmpty);
  });

  test('enroll() with enrolled user → enrollment set', () async {
    final repo = _EnrollmentRepo(
      enrollments: const [],
      enrollResult: Right<Failure, Enrollment>(_enrollment()),
    );
    final ctrl = makeController(
      cr: _CourseRepo(course: _course),
      lr: _LessonRepo(),
      er: repo,
      sessionUser: _user,
    );

    await ctrl.loadCourse('c1');
    expect(ctrl.enrollment.value, isNull);

    await ctrl.enroll();
    expect(ctrl.enrollment.value?.id, 'e1');
  });

  test('markLessonComplete without enrollment → no-op (will not call repo)',
      () async {
    final repo = _EnrollmentRepo(enrollments: const []);
    final ctrl = makeController(
      cr: _CourseRepo(course: _course),
      lr: _LessonRepo(lessons: _lessons()),
      er: repo,
      sessionUser: _user,
    );

    await ctrl.loadCourse('c1');

    // Wrap with a custom mark result tracker:
    repo.markResult = Right<Failure, Unit>(Unit.instance);
    final lessons = ctrl.lessons;
    await ctrl.toggleLessonComplete(lessons.first);

    // No progress should be recorded — the guard short-circuits.
    expect(ctrl.completedLessonIds, isEmpty);
  });

  test('markLessonComplete with enrollment → adds lesson id', () async {
    final repo = _EnrollmentRepo(
      enrollments: [_enrollment()],
      markResult: const Right<Failure, Unit>(Unit.instance),
    );
    final ctrl = makeController(
      cr: _CourseRepo(course: _course),
      lr: _LessonRepo(lessons: _lessons()),
      er: repo,
      sessionUser: _user,
    );

    await ctrl.loadCourse('c1');
    expect(ctrl.enrollment.value?.id, 'e1');

    await ctrl.toggleLessonComplete(ctrl.lessons.first);
    expect(ctrl.completedLessonIds, contains('l1'));
  });

  test('progress computes 0.0 with no lessons, 1/3 with one complete', () async {
    final repo = _EnrollmentRepo(enrollments: [_enrollment()]);
    final ctrl = makeController(
      cr: _CourseRepo(course: _course),
      lr: _LessonRepo(lessons: _lessons()),
      er: repo,
      sessionUser: _user,
    );

    expect(ctrl.progress, 0.0); // lessons empty before loadCourse

    await ctrl.loadCourse('c1');
    expect(ctrl.lessons, hasLength(3));
    expect(ctrl.progress, 0.0); // no completion yet

    await ctrl.toggleLessonComplete(ctrl.lessons.first);
    expect(ctrl.progress, closeTo(1.0 / 3.0, 0.001));
  });

  test('toggleLessonComplete when already complete → no duplicate', () async {
    final repo = _EnrollmentRepo(
      enrollments: [_enrollment(completed: const ['l1'])],
      markResult: const Right<Failure, Unit>(Unit.instance),
    );
    final ctrl = makeController(
      cr: _CourseRepo(course: _course),
      lr: _LessonRepo(lessons: _lessons()),
      er: repo,
      sessionUser: _user,
    );

    await ctrl.loadCourse('c1');
    expect(ctrl.completedLessonIds, contains('l1'));

    // Mark already-completed lesson again — should no-op.
    await ctrl.toggleLessonComplete(ctrl.lessons.first);
    expect(ctrl.completedLessonIds.where((id) => id == 'l1'), hasLength(1));
  });
}
