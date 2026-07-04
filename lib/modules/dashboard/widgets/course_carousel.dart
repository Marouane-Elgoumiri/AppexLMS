import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../domain/entities/course.dart';
import 'course_card.dart';

class CourseCarousel extends StatelessWidget {
  const CourseCarousel({
    super.key,
    required this.title,
    required this.items,
    this.onTap,
  });

  final String title;
  final List<Course> items;
  final void Function(Course course)? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: CourseCard.cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: items.length,
            separatorBuilder: (_, index) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (_, index) {
              final course = items[index];
              return CourseCard(
                title: course.title,
                instructor: course.instructor,
                category: course.category,
                onTap: onTap == null ? null : () => onTap!(course),
              );
            },
          ),
        ),
      ],
    );
  }
}
