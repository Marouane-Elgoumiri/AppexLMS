import 'package:flutter/material.dart';
import 'package:appex/app/theme/app_spacing.dart';
import 'package:appex/modules/dashboard/widgets/course_card.dart';

class CourseCarousel extends StatelessWidget {
  final String title;
  final List<dynamic> items;

  const CourseCarousel({super.key, required this.title, required this.items});

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
            itemBuilder: (_, index) => CourseCard(
              title: items[index]['title'] ?? 'No Title',
              instructor: items[index]['instructor'] ?? 'No Instructor',
            ),
          ),
        ),
      ],
    );
  }
}
