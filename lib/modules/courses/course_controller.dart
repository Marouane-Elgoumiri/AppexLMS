import 'package:get/get.dart';

import '../../domain/entities/course.dart';
import '../../domain/usecases/courses/get_course_by_id.dart';

class CourseController extends GetxController {
  CourseController({required this.getCourseById});
  final GetCourseById getCourseById;

  final courseId = ''.obs;
  final course = Rxn<Course>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
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
    final result = await getCourseById(id);
    isLoading.value = false;
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (c) => course.value = c,
    );
  }
}
