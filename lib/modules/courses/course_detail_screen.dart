import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'course_controller.dart';

class CourseDetail extends GetView<CourseController> {
  const CourseDetail({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadCourse('some-id');
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Course Detail')),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : GetBuilder<CourseController>(
                builder: (_) => Center(
                  child: Text(controller.course?['title'] ?? 'No course data'),
                ),
              ),
      ),
    );
  }
}
