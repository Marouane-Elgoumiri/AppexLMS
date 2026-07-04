import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../domain/entities/number_trivia.dart';

class TriviaCard extends StatelessWidget {
  const TriviaCard({super.key, required this.trivia});
  final NumberTrivia trivia;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surfaceContainerHighest,
            theme.colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${trivia.number}',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SelectableText(
            trivia.text,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
