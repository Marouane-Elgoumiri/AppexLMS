import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/enrollment.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/course_repository.dart';
import '../../domain/usecases/auth/auth_usecases.dart';
import '../../domain/usecases/enrollments/enroll_in_course.dart';
import '../../domain/usecases/user/get_current_user.dart';
import '../auth/auth_session.dart';

/// Sprint 5 — replaces the Sprint 3 placeholder. Loads the active user +
/// their enrollments + the corresponding Course rows (enrollments only
/// carry ids; we hydrate titles via the course repo so the carousel can
/// reuse the dashboard's `CourseCard`).
class ProfileController extends GetxController {
  ProfileController({
    required this.getCurrentUser,
    required this.getEnrollmentsForUser,
    required this.logoutUseCase,
    required this.courseRepository,
  });

  final GetCurrentUser getCurrentUser;
  final GetEnrollmentsForUser getEnrollmentsForUser;
  final LogoutUseCase logoutUseCase;
  final CourseRepository courseRepository;

  // Session is optional in case future paths want to read the cached user
  // instead of re-fetching via [getCurrentUser].
  final AuthSession _session = Get.find<AuthSession>();

  final Rxn<User> user = Rxn<User>();
  final RxList<Course> enrolledCourses = <Course>[].obs;
  final RxList<Enrollment> enrollments = <Enrollment>[].obs;

  final isLoading = false.obs;
  final isLoggingOut = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    bootstrap();
  }

  /// Warm the screen from the AuthSession's already-restored user, then
  /// fetch enrollments + course details.
  Future<void> bootstrap() async {
    isLoading.value = true;
    errorMessage.value = null;

    // Use the cached session user if present; re-fetch otherwise.
    User? active = _session.currentUser.value;
    if (active == null) {
      final userRes = await getCurrentUser();
      active = userRes.fold((_) => null, (u) => u);
    }

    if (active == null) {
      // No session — show empty state with sign-in prompt.
      user.value = null;
      enrolledCourses.clear();
      enrollments.clear();
      isLoading.value = false;
      return;
    }

    user.value = active;
    await _loadEnrollments(active.id);
    isLoading.value = false;
  }

  Future<void> _loadEnrollments(String uid) async {
    final result = await getEnrollmentsForUser(uid);
    await result.fold(
      (failure) async {
        // Enrollment fetch is best-effort — show a softer error than
        // blowing the whole screen away.
        errorMessage.value = 'Could not load enrollments: ${failure.message}';
        enrolledCourses.clear();
        enrollments.clear();
      },
      (list) async {
        enrollments.assignAll(list);
        // Hydrate Course rows so the carousel can render titles/instructors.
        final courses = <Course>[];
        for (final enrollment in list) {
          final courseRes =
              await courseRepository.getCourseById(enrollment.courseId);
          courseRes.fold((_) {/* skip missing rows */}, (c) => courses.add(c));
        }
        enrolledCourses.assignAll(courses);
      },
    );
  }

  Future<void> doLogout() async {
    isLoggingOut.value = true;
    final result = await logoutUseCase.call();
    isLoggingOut.value = false;
    await result.fold(
      (failure) async {
        errorMessage.value = failure.message;
      },
      (_) async {
        await _session.clear();
        user.value = null;
        enrolledCourses.clear();
        enrollments.clear();
        Get.offAllNamed(AppRoutes.login);
      },
    );
  }
}
