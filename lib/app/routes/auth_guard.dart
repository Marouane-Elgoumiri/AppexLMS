import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import '../../modules/auth/auth_session.dart';

/// Sprint 5 — route-level guard for any page that requires an authenticated
/// user. Attach to a [GetPage] via `middlewares: [AuthGuard()]`.
///
/// Reads the shared [AuthSession] (registered permanently from
/// [InitialBinding]). When the session has no current user, navigation is
/// redirected to `/login`. The Login route itself does NOT carry this guard
/// (use [LoginGuard] there instead).
class AuthGuard extends GetMiddleware {
  AuthGuard({super.priority});

  @override
  RouteSettings? redirect(String? route) {
    final session = Get.find<AuthSession>();
    // Wait for the splash-driven bootstrap to complete before deciding.
    // If a user is restored, let the navigation through; otherwise bounce.
    if (!session.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}

/// Inverse of [AuthGuard]: prevents an already-authenticated user from
/// re-entering `/login` (e.g., via deep-link or back button). Sends them
/// to `/dashboard` instead.
class LoginGuard extends GetMiddleware {
  LoginGuard({super.priority});

  @override
  RouteSettings? redirect(String? route) {
    final session = Get.find<AuthSession>();
    if (session.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.dashboard);
    }
    return null;
  }
}
