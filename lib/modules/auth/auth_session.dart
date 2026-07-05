import 'package:get/get.dart';

import '../../core/either.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

/// Sprint 5 — single source of truth for "who is the current user?".
///
/// Replaces the imperative `AuthController.currentUser.value` lookup that
/// other modules had no clean way to reach (AuthController was `lazyPut`
/// in AuthBinding, route-scoped). This service is `permanent:true` from
/// `InitialBinding` and outlives every route, so the route guard, the
/// Profile screen, the Course Detail enrollment flow, and the Splash
/// probe all share one state object.
///
/// Usage:
/// ```dart
/// final session = Get.find<AuthSession>();
/// final ok = session.isAuthenticated;
/// final user = session.currentUser.value; // reactive
/// await session.bootstrap();              // restore on app start
/// await session.clear();                  // on logout
/// ```
class AuthSession extends GetxService {
  AuthSession({required this.userRepository});

  final UserRepository userRepository;

  final Rxn<User> currentUser = Rxn<User>();
  final RxBool isBootstrapped = false.obs;

  bool get isAuthenticated => currentUser.value != null;

  /// Probes the underlying session store for an existing user.
  ///
  /// For the mock backend this always returns a stub user (the mock treats
  /// the data source as already-authenticated since Sprint 3). For Supabase
  /// it returns the user restored from `supabase.auth.currentSession` —
  /// `UnauthenticatedFailure` is the expected "no session" result.
  Future<Either<Failure, User>> bootstrap() async {
    final result = await userRepository.getCurrentUser();
    isBootstrapped.value = true;
    result.fold(
      (_) => currentUser.value = null,
      (user) => currentUser.value = user,
    );
    return result;
  }

  /// Sets the active user (called by AuthController after a successful
  /// login/register). Should NOT be invoked directly by other modules —
  /// route through [bootstrap] when restoring sessions, or use [clear]
  /// to log out.
  void setUser(User user) {
    currentUser.value = user;
  }

  Future<void> clear() async {
    currentUser.value = null;
  }
}
