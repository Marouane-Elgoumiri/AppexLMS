import 'package:flutter/material.dart';
import 'package:appex/app/theme/app_spacing.dart';
import 'package:appex/modules/splash/splash_controller.dart';
import 'package:get/get.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/appexlms_light.png',
              height: AppSpacing.xxxl,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('AppexLMS', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
