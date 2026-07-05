import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_spacing.dart';
import '../dashboard/widgets/course_carousel.dart';
import 'profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // No session — prompt sign-in.
        if (controller.user.value == null) {
          return _CenteredMessage(
            icon: Icons.lock_outline,
            text: 'You\'re not signed in.',
            actionLabel: 'Sign in',
            onAction: () => Get.offAllNamed(AppRoutes.login),
          );
        }

        final user = controller.user.value!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Identity card.
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : '?',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: theme.textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          user.email,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Error toast (best-effort enrollment fetch).
              Obx(() {
                final e = controller.errorMessage.value;
                if (e == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    e,
                    style: TextStyle(color: theme.colorScheme.error),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),

              // Enrolled courses.
              Obx(() {
                if (controller.enrolledCourses.isEmpty) {
                  return _EmptyEnrollments(onBrowse: _goToDashboard);
                }
                return CourseCarousel(
                  title: 'Your courses',
                  items: controller.enrolledCourses,
                  onTap: _openCourse,
                );
              }),

              const SizedBox(height: AppSpacing.xl),

              // Logout.
              Center(
                child: FilledButton.tonalIcon(
                  onPressed: controller.isLoggingOut.value
                      ? null
                      : controller.doLogout,
                  icon: controller.isLoggingOut.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.logout),
                  label: const Text('Log out'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _openCourse(dynamic course) {
    Get.toNamed(AppRoutes.courseDetail, arguments: course);
  }

  void _goToDashboard() {
    Get.offAllNamed(AppRoutes.dashboard);
  }
}

class _EmptyEnrollments extends StatelessWidget {
  const _EmptyEnrollments({required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No enrollments yet — explore the catalog to get started.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(onPressed: onBrowse, child: const Text('Browse courses')),
        ],
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.text,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String text;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 56),
              const SizedBox(height: AppSpacing.md),
            ],
            Text(text, textAlign: TextAlign.center),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: AppSpacing.md),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
