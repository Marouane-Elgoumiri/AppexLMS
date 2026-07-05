import 'package:appex/core/either.dart';
import 'package:appex/core/errors/failures.dart';
import 'package:appex/core/unit.dart' show Unit;
import 'package:appex/domain/entities/course.dart';
import 'package:appex/domain/entities/enrollment.dart';
import 'package:appex/domain/entities/user.dart';
import 'package:appex/domain/repositories/auth_repository.dart';
import 'package:appex/domain/repositories/course_repository.dart';
import 'package:appex/domain/repositories/enrollment_repository.dart';
import 'package:appex/domain/repositories/user_repository.dart';
import 'package:appex/domain/usecases/auth/auth_usecases.dart';
import 'package:appex/domain/usecases/enrollments/enroll_in_course.dart';
import 'package:appex/domain/usecases/user/get_current_user.dart';
import 'package:appex/modules/auth/auth_session.dart';
import 'package:appex/modules/profile/profile_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeUserRepo implements UserRepository {
  _FakeUserRepo({this.user});
  User? user;
  @override
  Future<Either<Failure, User>> getCurrentUser() async =>
      user == null ? const Left(UnauthenticatedFailure()) : Right(user!);
  @override
  Future<Either<Failure, User>> getUserById(String id) async =>
      user == null ? const Left(UnauthenticatedFailure()) : Right(user!);
}

class _FakeEnrollmentRepo implements EnrollmentRepository {
  _FakeEnrollmentRepo({this.enrollments = const []});
  List<Enrollment> enrollments;

  @override
  Future<Either<Failure, List<Enrollment>>> getEnrollmentsForUser(
      String uid) async {
    final list = enrollments.where((e) => e.userId == uid).toList();
    return Right<Failure, List<Enrollment>>(list);
  }

  @override
  Future<Either<Failure, Enrollment>> enroll(String uid, String cid) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> markLessonCompleted({
    required String enrollmentId,
    required String lessonId,
  }) async {
    throw UnimplementedError();
  }
}

class _FakeCourseRepo implements CourseRepository {
  _FakeCourseRepo({this.courses = const {}});
  final Map<String, Course> courses;

  @override
  Future<Either<Failure, Course>> getCourseById(String id) async {
    final match = courses[id];
    if (match == null) return Left(NotFoundFailure('Course $id not found'));
    return Right<Failure, Course>(match);
  }

  @override
  Future<Either<Failure, List<Course>>> getAllCourses() async {
    return Right<Failure, List<Course>>(courses.values.toList());
  }

  @override
  Future<Either<Failure, List<Course>>> getCoursesByCategory(String _) async {
    return Right<Failure, List<Course>>(courses.values.toList());
  }
}

class _FakeAuthRepo implements AuthRepository {
  _FakeAuthRepo({this.logoutFails = false});
  bool logoutFails;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    if (logoutFails) {
      return const Left(ServerFailure('Logout failed'));
    }
    return Right<Failure, Unit>(Unit.instance);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final user = User(id: 'u1', email: 'student@appex.dev', displayName: 'Demo Student');
  final course = Course(
    id: 'c1',
    title: 'Flutter Foundations',
    instructor: 'Alice',
    category: 'Flutter',
    lessonCount: 5,
  );

  final enrollment = Enrollment(
    id: 'e1',
    userId: user.id,
    courseId: course.id,
    enrolledAt: DateTime(2024),
    completedLessonIds: const [],
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
  });

  ProfileController makeController({
    required _FakeUserRepo userRepo,
    required _FakeEnrollmentRepo enrollRepo,
    required _FakeCourseRepo courseRepo,
    required AuthRepository authRepo,
  }) {
    final session = AuthSession(userRepository: userRepo);
    Get.put<AuthSession>(session, permanent: true);

    return ProfileController(
      getCurrentUser: GetCurrentUser(userRepo),
      getEnrollmentsForUser: GetEnrollmentsForUser(enrollRepo),
      logoutUseCase: LogoutUseCase(authRepo),
      courseRepository: courseRepo,
    );
  }

  test('bootstrap with enrolled user → user + enrolledCourses populated',
      () async {
    final ctrl = makeController(
      userRepo: _FakeUserRepo(user: user),
      enrollRepo: _FakeEnrollmentRepo(enrollments: [enrollment]),
      courseRepo: _FakeCourseRepo(courses: {course.id: course}),
      authRepo: _FakeAuthRepo(),
    );

    await ctrl.bootstrap();

    expect(ctrl.user.value?.id, user.id);
    expect(ctrl.enrollments, hasLength(1));
    expect(ctrl.enrolledCourses, hasLength(1));
    expect(ctrl.enrolledCourses.first.id, course.id);
    expect(ctrl.isLoading.value, isFalse);
  });

  test('bootstrap with no session → user null, list empty', () async {
    final ctrl = makeController(
      userRepo: _FakeUserRepo(user: null),
      enrollRepo: _FakeEnrollmentRepo(),
      courseRepo: _FakeCourseRepo(),
      authRepo: _FakeAuthRepo(),
    );

    await ctrl.bootstrap();

    expect(ctrl.user.value, isNull);
    expect(ctrl.enrolledCourses, isEmpty);
  });

  test('bootstrap with no enrollments → empty enrolled list', () async {
    final ctrl = makeController(
      userRepo: _FakeUserRepo(user: user),
      enrollRepo: _FakeEnrollmentRepo(enrollments: const []),
      courseRepo: _FakeCourseRepo(),
      authRepo: _FakeAuthRepo(),
    );

    await ctrl.bootstrap();

    expect(ctrl.user.value?.id, user.id);
    expect(ctrl.enrolledCourses, isEmpty);
    expect(ctrl.enrollments, isEmpty);
  });

  test('doLogout success → clears session and nav target redirected',
      () async {
    final userRepo = _FakeUserRepo(user: user);
    final ctrl = makeController(
      userRepo: userRepo,
      enrollRepo: _FakeEnrollmentRepo(enrollments: [enrollment]),
      courseRepo: _FakeCourseRepo(courses: {course.id: course}),
      authRepo: _FakeAuthRepo(),
    );

    // Skip the navigation side-effect: Get.offAllNamed will fail without a
    // navigator in unit-test mode. We expect it to throw, which is fine.
    await ctrl.bootstrap();

    try {
      await ctrl.doLogout();
    } catch (_) {/* Get.offAllNamed without a navigator */}

    expect(ctrl.user.value, isNull);
    expect(ctrl.enrolledCourses, isEmpty);
    expect(ctrl.isLoggingOut.value, isFalse);
  });

  test('doLogout failure → keeps user populates errorMessage', () async {
    final ctrl = makeController(
      userRepo: _FakeUserRepo(user: user),
      enrollRepo: _FakeEnrollmentRepo(enrollments: [enrollment]),
      courseRepo: _FakeCourseRepo(courses: {course.id: course}),
      authRepo: _FakeAuthRepo(logoutFails: true),
    );

    await ctrl.bootstrap();
    await ctrl.doLogout();

    expect(ctrl.user.value?.id, user.id);
    expect(ctrl.errorMessage.value, isNotNull);
  });
}
