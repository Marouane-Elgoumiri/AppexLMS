import 'package:get/get.dart';

import '../../domain/usecases/courses/get_course_by_id.dart';
import 'course_controller.dart';

class CourseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GetCourseById>(
      () => GetCourseById(Get.find()),
      fenix: true,
    );
    Get.lazyPut<CourseController>(
      () => CourseController(getCourseById: Get.find()),
    );
  }
}
