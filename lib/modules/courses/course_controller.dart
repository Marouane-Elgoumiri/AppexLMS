import 'package:get/get.dart';

class CourseController extends GetxController {
  final courseId = ''.obs;
  final isLoading = false.obs;

  Map<String, String>? course;

  void loadCourse(String id) {
    courseId.value = id;
    isLoading.value = true;
    // Simulate a network request to fetch course details
    Future.delayed(const Duration(seconds: 2), () {
      // Mock course data
      course = {
        'title': 'Course Title for $id',
        'instructor': 'Instructor Name',
        'lessons': 'This is a detailed description of the course with ID $id.',
      };
      isLoading.value = false;
      update(); // Notify GetBuilder to rebuild the UI with new course data
    });
  }
}
