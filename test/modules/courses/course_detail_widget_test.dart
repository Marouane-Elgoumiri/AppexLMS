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
import 'package:appex/modules/courses/course_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _CourseRepo implements CourseRepository {
  _CourseRepo(this._course);
  final Course _course;
  @override
  Future<Either<Failure, Course>> getCourseById(String id) async =>
      Right<Failure, Course>(_course);
  @override
  Future<Either<Failure, List<Course>>> getAllCourses() async =>
      Right<Failure, List<Course>>([_course]);
  @override
  Future<Either<Failure, List<Course>>> getCoursesByCategory(String _) async =>
      Right<Failure, List<Course>>([_course]);
}

class _LessonRepo implements LessonRepository {
  _LessonRepo(this._lessons);
  final List<Lesson> _lessons;
  @override
  Future<Either<Failure, List<Lesson>>> getLessonsForCourse(String _) async =>
      Right<Failure, List<Lesson>>(_lessons);
}

class _EnrollmentRepo implements EnrollmentRepository {
  _EnrollmentRepo({this.enrollments = const []});
  final List<Enrollment> enrollments;

  @override
  Future<Either<Failure, List<Enrollment>>> getEnrollmentsForUser(String uid) async {
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
  }) async => const Right<Failure, Unit>(Unit.instance);
}

class _UserRepo implements UserRepository {
  @override
  Future<Either<Failure, User>> getCurrentUser() async =>
      const Left(UnauthenticatedFailure());
  @override
  Future<Either<Failure, User>> getUserById(String _) async =>
      const Left(UnauthenticatedFailure());
}

const _user = User(id: 'u1', email: 'student@appex.dev', displayName: 'Demo Student');

final _course = Course(
  id: 'c1',
  title: 'Flutter Foundations',
  instructor: 'Alice',
  category: 'Flutter',
  lessonCount: 3,
);

final _lessons = [
  Lesson(id: 'l1', courseId: 'c1', title: 'Lesson 1', order: 1, durationSeconds: 360),
  Lesson(id: 'l2', courseId: 'c1', title: 'Lesson 2', order: 2, durationSeconds: 420),
  Lesson(id: 'l3', courseId: 'c1', title: 'Lesson 3', order: 3, durationSeconds: 300),
];

Enrollment _enrollment({List<String> completed = const []}) => Enrollment(
      id: 'e1',
      userId: _user.id,
      courseId: _course.id,
      enrolledAt: DateTime(2024),
      completedLessonIds: completed,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
  });

  CourseController makeController({_EnrollmentRepo? enrollRepo}) {
    final session = AuthSession(userRepository: _UserRepo());
    session.setUser(_user);
    Get.put<AuthSession>(session, permanent: true);

    final er = enrollRepo ?? _EnrollmentRepo();

    return Get.put(CourseController(
      getCourseById: GetCourseById(_CourseRepo(_course)),
      getLessonsForCourse: GetLessonsForCourse(_LessonRepo(_lessons)),
      enrollInCourse: EnrollInCourse(er),
      markLessonCompleted: MarkLessonCompleted(er),
      enrollmentRepository: er,
    ));
  }

  testWidgets('CourseDetail — Enroll button visible when no enrollment',
      (tester) async {
    Get.testMode = true;
    final ctrl = makeController(enrollRepo: _EnrollmentRepo(enrollments: const []));
    // Drive initial load synchronously so the screen renders populated.
    await ctrl.loadCourse(_course.id);

    await tester.pumpWidget(GetMaterialApp(home: const CourseDetail()));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    // Course title appears
    expect(find.text('Flutter Foundations'), findsOneWidget);
    // Enroll button visible
    expect(find.text('Enroll'), findsOneWidget);
    // No progress bar (enrollment null)
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('CourseDetail — Lesson list visible and shows completion status',
      (tester) async {
    Get.testMode = true;
    final ctrl = makeController(
      enrollRepo: _EnrollmentRepo(
        enrollments: [_enrollment(completed: const ['l1'])],
      ),
    );
    await ctrl.loadCourse(_course.id);

    await tester.pumpWidget(GetMaterialApp(home: const CourseDetail()));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    // Lessons visible
    expect(find.text('Lessons'), findsOneWidget);
    expect(find.text('Lesson 1'), findsOneWidget);
    expect(find.text('Lesson 2'), findsOneWidget);
    expect(find.text('Lesson 3'), findsOneWidget);

    // Enrolled message visible (enrollment already exists)
    expect(find.text('Enroll'), findsNothing);
    expect(
      find.textContaining("You're enrolled"),
      findsOneWidget,
    );

    // Progress bar shown
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    // Progress text = 33%
    expect(find.text('33%'), findsOneWidget);
  });
}
