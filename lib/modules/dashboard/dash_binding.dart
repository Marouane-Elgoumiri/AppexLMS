import 'package:get/get.dart';

import '../../domain/usecases/courses/get_courses.dart';
import 'dash_controller.dart';

class DashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GetCourses>(() => GetCourses(Get.find()), fenix: true);
    Get.lazyPut<GetCoursesByCategory>(
      () => GetCoursesByCategory(Get.find()),
      fenix: true,
    );
    Get.lazyPut<DashController>(
      () => DashController(getCourses: Get.find(), getByCategory: Get.find()),
    );
  }
}
