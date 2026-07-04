import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_spacing.dart';
import 'auth_controller.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: constraints.maxHeight * 0.08),
                  Image.asset(
                    "assets/appexlms_dark.png",
                    height: AppSpacing.xxxl,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  Text(
                    'Welcome to AppexLMS',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your learning journey starts here.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  GetBuilder<AuthController>(
                    builder: (ctrl) {
                      if (!ctrl.isRegistered) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        children: [
                          TextField(
                            onChanged: (v) => ctrl.displayName.value = v,
                            decoration: const InputDecoration(
                              hintText: 'Display name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      );
                    },
                  ),
                  TextField(
                    onChanged: (v) => controller.email.value = v,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Obx(
                    () => TextField(
                      obscureText: !controller.isPasswordVisible.value,
                      onChanged: (v) => controller.password.value = v,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Obx(
                    () => ElevatedButton(
                      onPressed: controller.isFormValid &&
                              !controller.isLoading.value
                          ? controller.submit
                          : null,
                      child: GetBuilder<AuthController>(
                        builder: (ctrl) => Text(
                          ctrl.isRegistered ? 'Create account' : 'Login',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GetBuilder<AuthController>(
                    builder: (ctrl) => TextButton(
                      onPressed: ctrl.switchToRegister,
                      child: Text(
                        ctrl.isRegistered
                            ? 'Already have an account? Sign In'
                            : "Don't have an account? Sign Up",
                      ),
                    ),
                  ),
                  Obx(
                    () => controller.errorMessage.value == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding:
                                const EdgeInsets.only(top: AppSpacing.sm),
                            child: Text(
                              controller.errorMessage.value!,
                              style: TextStyle(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                  ),
                  Obx(
                    () => controller.isLoading.value
                        ? const Padding(
                            padding: EdgeInsets.only(top: AppSpacing.sm),
                            child: LinearProgressIndicator(),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.numberTrivia),
                    icon: const Icon(Icons.shuffle),
                    label: const Text('Try the Number Trivia demo'),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.06),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
