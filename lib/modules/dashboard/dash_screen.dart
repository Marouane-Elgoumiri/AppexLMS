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
                () => controller.isLoading.value ||
                        controller.isFiltering.value
                    ? const LinearProgressIndicator(minHeight: 4)
                    : const SizedBox.shrink(),
              ),

              // Status row — category + last refreshed.
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

              // Category chips.
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

              // Sprint 5 — body swaps between carousel trio (All) and
              // filtered list (any other category).
              Obx(() => controller.isFilteringActive
                  ? _FilteredView(controller: controller, open: _open)
                  : _AllView(controller: controller, open: _open)),

              Obx(
                () => controller.errorMessage.value == null
                    ? const SizedBox.shrink()
                    : _ErrorBanner(
                        message: controller.errorMessage.value!,
                        onRetry: controller.refreshDashboard,
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
            if (i == 1) {
              // Search — coming in a future sprint (intentionally a no-op
              // for now; tapping just selects the tab).
              Get.snackbar(
                'Search',
                'Search comes in a future sprint.',
                snackPosition: SnackPosition.BOTTOM,
              );
            } else if (i == 2) {
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

/// 'All' chip — three carousels + Hero Banner.
class _AllView extends StatelessWidget {
  const _AllView({required this.controller, required this.open});

  final DashController controller;
  final void Function(dynamic course) open;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Empty state (no courses and not currently loading).
      if (controller.allCourses.isEmpty &&
          !controller.isLoading.value &&
          controller.errorMessage.value == null) {
        return _EmptyState(
          message: 'No courses available yet.',
          onRetry: controller.refreshDashboard,
        );
      }
      return Column(
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
            onTap: open,
          ),
          const SizedBox(height: AppSpacing.lg),
          CourseCarousel(
            title: 'Popular Courses',
            items: controller.recommendedCourses,
            onTap: open,
          ),
          const SizedBox(height: AppSpacing.lg),
          CourseCarousel(
            title: 'New Releases',
            items: controller.newCourses,
            onTap: open,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      );
    });
  }
}

/// Filtered-list view — replaces the carousel trio when a category chip
/// other than 'All' is selected. Reuses [CourseCarousel] for visual parity.
class _FilteredView extends StatelessWidget {
  const _FilteredView({required this.controller, required this.open});

  final DashController controller;
  final void Function(dynamic course) open;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Filter fetch error.
      if (controller.filterError.value != null) {
        return _ErrorBanner(
          message: controller.filterError.value!,
          onRetry: controller.refreshDashboard,
        );
      }

      // Filter fetch in flight.
      if (controller.isFiltering.value &&
          controller.filteredCourses.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      // Empty filter result.
      if (controller.filteredCourses.isEmpty) {
        return _EmptyState(
          message:
              'No courses in "${controller.category.value}". Try another category.',
          onRetry: null,
        );
      }

      return CourseCarousel(
        title: 'Category: ${controller.category.value}',
        items: controller.filteredCourses,
        onTap: open,
      );
    });
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}
