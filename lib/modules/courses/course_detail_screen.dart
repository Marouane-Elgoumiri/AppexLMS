import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_spacing.dart';
import '../../domain/entities/lesson.dart';
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
          return _CenteredMessage(
            text: failure,
            color: theme.colorScheme.error,
            onRetry: () => controller.loadCourse(controller.courseId.value),
            retryLabel: 'Retry',
          );
        }
        final c = controller.course.value;
        if (c == null) {
          return const _CenteredMessage(text: 'No course data');
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero banner — category tile (placeholder for imageUrl).
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
              Text(
                '${c.lessonCount} lessons',
                style: theme.textTheme.bodyLarge,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Sprint 5 — progress bar (visible only when enrolled).
              Obx(() {
                if (controller.enrollment.value == null) return const SizedBox.shrink();
                final p = controller.progress;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Progress', style: theme.textTheme.bodyMedium),
                        Text(
                          '${(p * 100).round()}%',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    LinearProgressIndicator(value: p, minHeight: 6),
                  ],
                );
              }),

              const SizedBox(height: AppSpacing.lg),

              // Enroll / Continue action.
              Obx(() {
                if (controller.userId.value.isEmpty) {
                  return const Text('Sign in to enroll and track progress.');
                }
                if (controller.enrollment.value == null) {
                  return FilledButton.icon(
                    onPressed: controller.isEnrolling.value
                        ? null
                        : controller.enroll,
                    icon: controller.isEnrolling.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.school),
                    label: const Text('Enroll'),
                  );
                }
                return const Text(
                  'You\'re enrolled — tap a lesson to mark it complete.',
                  style: TextStyle(fontWeight: FontWeight.w500),
                );
              }),

              const SizedBox(height: AppSpacing.lg),

              // Lessons list — empty state, error swallowed state, or list.
              Obx(() {
                if (controller.lessons.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: _CenteredMessage(text: 'No lessons published yet.'),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lessons', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.lessons.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: AppSpacing.sm),
                      itemBuilder: (_, i) {
                        final lesson = controller.lessons[i];
                        return _LessonTile(
                          lesson: lesson,
                          isComplete:
                              controller.completedLessonIds.contains(lesson.id),
                          canToggle: controller.enrollment.value != null &&
                              controller.userId.value.isNotEmpty,
                          isToggling: controller.isToggling.value,
                          onTap: () =>
                              controller.toggleLessonComplete(lesson),
                        );
                      },
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.lesson,
    required this.isComplete,
    required this.canToggle,
    required this.isToggling,
    required this.onTap,
  });

  final Lesson lesson;
  final bool isComplete;
  final bool canToggle;
  final bool isToggling;
  final VoidCallback onTap;

  String _fmtDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: Text(
          '${lesson.order}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      title: Text(lesson.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(_fmtDuration(lesson.durationSeconds)),
      trailing: isToggling
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              icon: Icon(
                isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isComplete
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: canToggle ? onTap : null,
              tooltip: canToggle
                  ? (isComplete ? 'Already complete' : 'Mark complete')
                  : 'Enroll to track progress',
            ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.text,
    this.color,
    this.onRetry,
    this.retryLabel,
  });

  final String text;
  final Color? color;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: color == null ? null : TextStyle(color: color)),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              TextButton(onPressed: onRetry, child: Text(retryLabel ?? 'Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
