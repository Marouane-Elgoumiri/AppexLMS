import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_spacing.dart';
import 'dash_controller.dart';
import 'widgets/course_carousel.dart';
import 'widgets/hero_banner.dart';

class DashScreen extends GetView<DashController> {
  const DashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AppexLMS')),
      body: RefreshIndicator(
        onRefresh: controller.refreshDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Obx(
                () => controller.isLoading.value
                    ? const LinearProgressIndicator(minHeight: 4)
                    : const SizedBox.shrink(),
              ),

              Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Category: ${controller.category.value.isEmpty ? "All" : controller.category.value}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Updated: ${_formatTime(controller.lastRefresh.value)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: AppSpacing.xxl + AppSpacing.xs,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  children: ['All', 'Flutter', 'Dart', 'Design', 'Backend']
                      .map(
                        (cat) => Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: Obx(
                            () => ChoiceChip(
                              label: Text(cat),
                              selected:
                                  controller.category.value == cat ||
                                  (cat == 'All' &&
                                      controller.category.value.isEmpty),
                              onSelected: (_) => controller.setCategory(
                                cat == 'All' ? '' : cat,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              HeroBanner(
                courseTitle: 'Flutter for Beginners',
                instructor: 'John Doe',
                onContinue: () => Get.toNamed(AppRoutes.courseDetail),
              ),

              const SizedBox(height: AppSpacing.lg),
              CourseCarousel(
                title: 'Continue Learning',
                items: controller.popularCourses,
                onTap: _open,
              ),
              const SizedBox(height: AppSpacing.lg),
              CourseCarousel(
                title: 'Popular Courses',
                items: controller.recommendedCourses,
                onTap: _open,
              ),
              const SizedBox(height: AppSpacing.lg),
              CourseCarousel(
                title: 'New Releases',
                items: controller.newCourses,
                onTap: _open,
              ),

              Obx(
                () => controller.errorMessage.value == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          controller.errorMessage.value!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: (i) {
            controller.changePage(i);
            if (i == 2) {
              Get.toNamed(AppRoutes.profile);
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  void _open(dynamic course) {
    Get.toNamed(AppRoutes.courseDetail, arguments: course);
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
