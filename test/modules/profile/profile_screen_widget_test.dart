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
import 'package:appex/core/either.dart';
import 'package:appex/core/errors/failures.dart';
import 'package:appex/core/unit.dart';
import 'package:appex/modules/auth/auth_session.dart';
import 'package:appex/modules/profile/profile_controller.dart';
import 'package:appex/modules/profile/profile_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _UserRepo implements UserRepository {
  @override
  Future<Either<Failure, User>> getCurrentUser() async =>
      const Left(UnauthenticatedFailure());
  @override
  Future<Either<Failure, User>> getUserById(String _) async =>
      const Left(UnauthenticatedFailure());
}

class _EnrollRepo implements EnrollmentRepository {
  @override
  Future<Either<Failure, List<Enrollment>>> getEnrollmentsForUser(String _) async =>
      const Right<Failure, List<Enrollment>>([]);
  @override
  Future<Either<Failure, Enrollment>> enroll(String uid, String cid) async =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, Unit>> markLessonCompleted({
    required String enrollmentId,
    required String lessonId,
  }) async => throw UnimplementedError();
}

class _CourseRepo implements CourseRepository {
  @override
  Future<Either<Failure, List<Course>>> getAllCourses() async =>
      const Right<Failure, List<Course>>([]);
  @override
  Future<Either<Failure, List<Course>>> getCoursesByCategory(String _) async =>
      const Right<Failure, List<Course>>([]);
  @override
  Future<Either<Failure, Course>> getCourseById(String _) async =>
      Left(NotFoundFailure('not found'));
}

class _AuthRepo implements AuthRepository {
  @override
  Future<Either<Failure, User>> login({required String email, required String password}) async =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, User>> register({required String email, required String password, required String displayName}) async =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, Unit>> logout() async =>
      const Right<Failure, Unit>(Unit.instance);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
  });

  testWidgets('ProfileScreen — empty state shows "No enrollments yet"', (tester) async {
    // Stub repos + session via Get.put.
    final userRepo = _UserRepo();
    final session = AuthSession(userRepository: userRepo);
    final user = User(id: 'u1', email: 'student@appex.dev', displayName: 'Demo Student');
    session.setUser(user);
    Get.put<AuthSession>(session, permanent: true);

    // Wire ProfileController manually so the screen has something to bind to.
    final profileCtrl = Get.put(ProfileController(
      getCurrentUser: GetCurrentUser(userRepo),
      getEnrollmentsForUser: GetEnrollmentsForUser(_EnrollRepo()),
      logoutUseCase: LogoutUseCase(_AuthRepo()),
      courseRepository: _CourseRepo(),
    ));

    await tester.pumpWidget(GetMaterialApp(home: const ProfileScreen()));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(
      find.text('No enrollments yet — explore the catalog to get started.'),
      findsOneWidget,
    );
    expect(find.text('Browse courses'), findsOneWidget);
    expect(profileCtrl.user.value?.id, 'u1');
  });
}
