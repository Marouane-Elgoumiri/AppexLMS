import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_spacing.dart';
import 'course_controller.dart';

class CourseDetail extends GetView<CourseController> {
  const CourseDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Course Detail')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final failure = controller.errorMessage.value;
        if (failure != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                failure,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          );
        }
        final c = controller.course.value;
        if (c == null) {
          return const Center(child: Text('No course data'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.md),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: theme.colorScheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: Text(
                    c.category,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(c.title, style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Instructor: ${c.instructor}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('${c.lessonCount} lessons', style: theme.textTheme.bodyLarge),
            ],
          ),
        );
      }),
    );
  }
}
