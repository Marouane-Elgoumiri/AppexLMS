import 'package:get/get.dart';

class CourseController extends GetxController {
  final courseId = ''.obs;

  void loadCourse(String id) {
    courseId.value = id;
  }
}
