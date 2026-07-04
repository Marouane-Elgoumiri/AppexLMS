import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_spacing.dart';
import 'number_trivia_controller.dart';
import 'widgets/trivia_card.dart';

class NumberTriviaScreen extends GetView<NumberTriviaController> {
  const NumberTriviaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Number Trivia')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sprint 3 demo',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Get.theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Clean Architecture in action',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Enter a number (or roll a random one) to fetch trivia from '
                'numbersapi.com via Dio. The data flows: '
                'Controller → UseCase → Repository → Dio → JSON → Entity.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      onChanged: controller.onInputChanged,
                      onSubmitted: (_) => controller.getConcreteTrivia(),
                      decoration: const InputDecoration(
                        hintText: 'e.g. 42',
                        prefixIcon: Icon(Icons.tag),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  ElevatedButton.icon(
                    onPressed: () => controller.getConcreteTrivia(),
                    icon: const Icon(Icons.search),
                    label: const Text('Get'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Obx(
                () => OutlinedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.getRandomTrivia,
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Surprise me'),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final error = controller.errorMessage.value;
                if (error != null) {
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: Text(error)),
                      ],
                    ),
                  );
                }
                final trv = controller.trivia.value;
                if (trv == null) {
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline),
                        const SizedBox(width: AppSpacing.sm),
                        const Expanded(
                          child: Text('Pick a number above to begin.'),
                        ),
                      ],
                    ),
                  );
                }
                return TriviaCard(trivia: trv);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
