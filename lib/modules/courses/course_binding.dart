import 'package:get/get.dart';

import '../../domain/repositories/enrollment_repository.dart';
import '../../domain/usecases/courses/get_course_by_id.dart';
import '../../domain/usecases/enrollments/enroll_in_course.dart';
import '../../domain/usecases/enrollments/mark_lesson_completed.dart';
import '../../domain/usecases/lessons/get_lessons_for_course.dart';
import 'course_controller.dart';

class CourseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GetCourseById>(
      () => GetCourseById(Get.find()),
      fenix: true,
    );
    Get.lazyPut<GetLessonsForCourse>(
      () => GetLessonsForCourse(Get.find()),
      fenix: true,
    );
    Get.lazyPut<EnrollInCourse>(
      () => EnrollInCourse(Get.find()),
      fenix: true,
    );
    Get.lazyPut<MarkLessonCompleted>(
      () => MarkLessonCompleted(Get.find()),
      fenix: true,
    );

    // Direct repo access (we read enrollments; routes through the use-case
    // layer only for side-effecting enroll/complete).
    Get.lazyPut<CourseController>(
      () => CourseController(
        getCourseById: Get.find(),
        getLessonsForCourse: Get.find(),
        enrollInCourse: Get.find(),
        markLessonCompleted: Get.find(),
        enrollmentRepository: Get.find<EnrollmentRepository>(),
      ),
    );
  }
}
