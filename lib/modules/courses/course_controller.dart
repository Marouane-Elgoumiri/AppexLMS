import 'package:get/get.dart';

import '../../domain/entities/course.dart';
import '../../domain/entities/enrollment.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/repositories/enrollment_repository.dart';
import '../../domain/usecases/courses/get_course_by_id.dart';
import '../../domain/usecases/enrollments/enroll_in_course.dart';
import '../../domain/usecases/enrollments/mark_lesson_completed.dart';
import '../../domain/usecases/lessons/get_lessons_for_course.dart';
import '../auth/auth_session.dart';

/// Sprint 5 — CourseDetail's controller. Extends the original `loadCourse`
/// behavior with three new concerns:
///   - fetch lessons for the course (parallel with course fetch)
///   - hydrate the active user's enrollment for THIS course (if any)
///   - support enrolling + marking lessons complete
///
/// The student identity is read from [AuthSession] (registered permanently
/// by `InitialBinding`); we don't re-fetch the user.
class CourseController extends GetxController {
  CourseController({
    required this.getCourseById,
    required this.getLessonsForCourse,
    required this.enrollInCourse,
    required this.markLessonCompleted,
    required this.enrollmentRepository,
  });

  final GetCourseById getCourseById;
  final GetLessonsForCourse getLessonsForCourse;
  final EnrollInCourse enrollInCourse;
  final MarkLessonCompleted markLessonCompleted;
  // Direct repo reference for "has the user already enrolled?" reads.
  // Sprint 5 keeps the use-case wrappers for the side-effecting operations
  // (enroll / markComplete) but reads go through the repo for parity with
  // `ProfileController.getEnrollmentsForUser`.
  final EnrollmentRepository enrollmentRepository;

  final courseId = ''.obs;
  final Rxn<Course> course = Rxn<Course>();

  final RxList<Lesson> lessons = <Lesson>[].obs;
  final Rxn<Enrollment> enrollment = Rxn<Enrollment>();
  final RxList<String> completedLessonIds = <String>[].obs;

  final isLoading = false.obs;
  final isEnrolling = false.obs;
  final isToggling = false.obs;
  final errorMessage = RxnString();

  /// Active user id (resolved in [onInit]). Empty when no session — the
  /// loaded screen then shows a "please sign in" message.
  final RxString userId = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Resolve the active user id (or empty if no session).
    final session = Get.find<AuthSession>();
    userId.value = session.currentUser.value?.id ?? '';

    final arg = Get.arguments;
    if (arg is Course) {
      loadCourse(arg.id);
    } else if (arg is String) {
      loadCourse(arg);
    }
  }

  Future<void> loadCourse(String id) async {
    courseId.value = id;
    isLoading.value = true;
    errorMessage.value = null;
    lessons.clear();
    enrollment.value = null;
    completedLessonIds.clear();

    final courseRes = await getCourseById(id);
    final lessonsRes = await getLessonsForCourse(id);

    isLoading.value = false;

    courseRes.fold(
      (failure) => errorMessage.value = failure.message,
      (c) => course.value = c,
    );

    lessonsRes.fold(
      (failure) {
        // Lessons are a soft failure — don't clobber the course-error slot.
        if (errorMessage.value == null) {
          errorMessage.value = failure.message;
        }
      },
      (list) => lessons.assignAll(list),
    );

    // After we have the course + lessons, hydrate the user's existing
    // enrollment for THIS course (so the UI knows whether to render
    // "Enroll" or "Continue" + a progress bar).
    await _hydrateEnrollmentForCourse(id);
  }

  Future<void> _hydrateEnrollmentForCourse(String cId) async {
    if (userId.value.isEmpty) {
      return;
    }

    final result = await enrollmentRepository.getEnrollmentsForUser(
      userId.value,
    );

    result.fold(
      (_) {/* no-op — enrollment is optional */},
      (list) {
        final match = list.where((e) => e.courseId == cId).toList();
        if (match.isEmpty) {
          enrollment.value = null;
          completedLessonIds.clear();
        } else {
          enrollment.value = match.first;
          completedLessonIds.assignAll(match.first.completedLessonIds);
        }
      },
    );
  }

  /// User tapped the "Enroll" button.
  Future<void> enroll() async {
    if (userId.value.isEmpty) {
      _toast('Sign in first', 'You must be signed in to enroll.');
      return;
    }
    isEnrolling.value = true;
    final result = await enrollInCourse(
      userId: userId.value,
      courseId: courseId.value,
    );
    isEnrolling.value = false;
    result.fold(
      (failure) => _toast('Enroll failed', failure.message),
      (enrollmentRow) {
        enrollment.value = enrollmentRow;
        completedLessonIds.assignAll(enrollmentRow.completedLessonIds);
        _toast('Enrolled', 'Welcome to ${course.value?.title ?? "the course"}!');
      },
    );
  }

  /// User tapped a lesson's check icon. If not enrolled, prompt. If already
  /// completed, this is a no-op (the repo's `markLessonCompleted` RPC is
  /// idempotent but we short-circuit to save a round-trip).
  Future<void> toggleLessonComplete(Lesson lesson) async {
    if (userId.value.isEmpty) {
      _toast('Sign in first', 'You must be signed in to track progress.');
      return;
    }
    final enrollmentRow = enrollment.value;
    if (enrollmentRow == null) {
      _toast('Enroll first', 'Tap "Enroll" to start tracking progress.');
      return;
    }
    if (completedLessonIds.contains(lesson.id)) {
      _toast('Already complete', '"${lesson.title}" is already done.');
      return;
    }

    isToggling.value = true;
    final result = await markLessonCompleted(
      enrollmentId: enrollmentRow.id,
      lessonId: lesson.id,
    );
    isToggling.value = false;

    result.fold(
      (failure) => _toast('Could not mark complete', failure.message),
      (_) {
        completedLessonIds.add(lesson.id);
        _toast('Lesson complete', '"${lesson.title}" marked complete.');
      },
    );
  }

  /// Computed progress fraction in [0,1]. Reactive via [lessons] +
  /// [completedLessonIds]. Does NOT use `Enrollment.progress` (the entity's
  /// getter has a divide-by-self bug; the controller computes fresh here).
  double get progress {
    if (lessons.isEmpty) return 0.0;
    return completedLessonIds.length / lessons.length;
  }

  /// Helper: emit a SnackBar if Get's root controller is registered (mirrors
  /// the safety pattern in `DashController._snackBar`).
  void _toast(String title, String body) {
    if (Get.isRegistered<GetMaterialController>()) {
      Get.snackbar(title, body, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
