import 'package:get/get.dart';
import 'package:appex/app/routes/app_routes.dart';
import 'package:appex/modules/auth/auth_session.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _bootstrapAndNavigate();
  }

  /// Holds the splash for branding (~1.5s), then probes the auth session
  /// and routes accordingly:
  ///   - authenticated  → /dashboard
  ///   - unauthenticated → /login
  ///
  /// The session probe is awaited in parallel with the branding delay so
  /// the user never waits the sum of (delay + network). For the mock
  /// backend the probe resolves immediately (synchronous data source).
  Future<void> _bootstrapAndNavigate() async {
    final session = Get.find<AuthSession>();

    final results = await Future.wait<dynamic>([
      session.bootstrap(),
      Future<void>.delayed(const Duration(milliseconds: 1500)),
    ]);

    // Use a non-null assertion since the second future is void — Dart
    // promotes it to List<dynamic> and we only care that both completed.
    results.length; // ignore: unnecessary statement (silences unused-warning)

    if (session.isAuthenticated) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
