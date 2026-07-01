import 'package:flutter/material.dart';
import 'package:appex/app/theme/app_spacing.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.title, required this.instructor});

  final String title;
  final String instructor;

  static const double cardWidth = 152;
  static const double cardHeight = 200;
  static const double imageHeight = 120;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            child: Container(
              width: cardWidth,
              height: imageHeight,
              color: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Flexible(
            child: Text(
              title,
              style: theme.textTheme.bodyLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            instructor,
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
