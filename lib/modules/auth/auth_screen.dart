import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appex/app/theme/app_spacing.dart';
import 'package:appex/modules/auth/auth_controller.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: constraints.maxHeight * 0.12),
                  Image.asset(
                    "assets/appexlms_dark.png",
                    height: AppSpacing.xxxl,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  Text(
                    'Welcome to AppexLMS',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your learning journey starts here.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    "Sign in to continue",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextField(
                    onChanged: (value) => controller.email.value = value,
                    decoration: InputDecoration(
                      hintText: "Email",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    obscureText: true,
                    onChanged: (value) => controller.password.value = value,
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Obx(
                    () => ElevatedButton(
                      onPressed: controller.isFormValid
                          ? controller.login
                          : null,
                      child: Text("Login"),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GetBuilder<AuthController>(
                    builder: (controller) {
                      return TextButton(
                        onPressed: () => controller.switchToRegister(),
                        child: Text("Don't have an account? Sign Up"),
                      );
                    },
                  ),
                  Obx(
                    () => controller.isLoading.value
                        ? LinearProgressIndicator()
                        : const SizedBox.shrink(),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
