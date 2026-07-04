import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.title,
    required this.instructor,
    this.category,
    this.onTap,
  });

  final String title;
  final String instructor;
  final String? category;
  final VoidCallback? onTap;

  static const double cardWidth = 152;
  static const double cardHeight = 200;
  static const double imageHeight = 120;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = SizedBox(
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
              alignment: Alignment.center,
              child: Text(
                category ?? 'Appex',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
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

    return onTap == null
        ? card
        : InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            child: card,
          );
  }
}
