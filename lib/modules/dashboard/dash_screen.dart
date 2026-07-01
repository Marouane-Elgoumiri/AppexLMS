import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appex/app/theme/app_spacing.dart';
import 'package:appex/app/routes/app_routes.dart';
import 'package:appex/modules/dashboard/dash_controller.dart';
import 'package:appex/modules/dashboard/widgets/course_carousel.dart';
import 'package:appex/modules/dashboard/widgets/hero_banner.dart';

class DashScreen extends GetView<DashController> {
  const DashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AppexLMS'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeroBanner(
              courseTitle: 'Flutter for Beginners',
              instructor: 'John Doe',
              onContinue: () => Get.toNamed(AppRoutes.courseDetail),
            ),
            const SizedBox(height: AppSpacing.lg),
            CourseCarousel(
              title: 'Continue Learning',
              items: controller.popularCourses,
            ),
            const SizedBox(height: AppSpacing.lg),
            CourseCarousel(
              title: 'Popular Courses',
              items: controller.recommendedCourses,
            ),
            const SizedBox(height: AppSpacing.lg),
            CourseCarousel(
              title: 'New Releases',
              items: controller.newCourses,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.selectedIndex.value,
        onTap: controller.changePage,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      )),
    );
  }
}
