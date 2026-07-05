import 'package:appex/app/routes/auth_guard.dart';
import 'package:appex/app/routes/app_routes.dart';
import 'package:appex/core/either.dart';
import 'package:appex/core/errors/failures.dart';
import 'package:appex/domain/entities/user.dart';
import 'package:appex/domain/repositories/user_repository.dart';
import 'package:appex/modules/auth/auth_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory user repo — AuthSession just needs the result of
/// `getCurrentUser`. We never invoke either method in guard tests since
/// the session is hydrated directly via [AuthSession.setUser].
class _Repo implements UserRepository {
  @override
  Future<Either<Failure, User>> getCurrentUser() async =>
      const Left(UnauthenticatedFailure());

  @override
  Future<Either<Failure, User>> getUserById(String id) async =>
      const Left(UnauthenticatedFailure());
}

const _user = User(id: 'u1', email: 'a@b.com', displayName: 'Alice');

AuthSession _makeSession({User? user}) {
  final session = AuthSession(userRepository: _Repo());
  if (user != null) {
    session.setUser(user);
  }
  return session;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
  });

  test('AuthGuard.redirect → /login when no session user', () {
    final session = _makeSession(user: null);
    Get.put<AuthSession>(session, permanent: true);

    final guard = AuthGuard();
    final result = guard.redirect(AppRoutes.dashboard);

    expect(result, isNotNull);
    expect(result!.name, AppRoutes.login);
  });

  test('AuthGuard.redirect → null when session has a user', () {
    final session = _makeSession(user: _user);
    Get.put<AuthSession>(session, permanent: true);

    final guard = AuthGuard();
    final result = guard.redirect(AppRoutes.dashboard);

    expect(result, isNull);
  });

  test('LoginGuard.redirect → /dashboard when session has a user', () {
    final session = _makeSession(user: _user);
    Get.put<AuthSession>(session, permanent: true);

    final guard = LoginGuard();
    final result = guard.redirect(AppRoutes.login);

    expect(result, isNotNull);
    expect(result!.name, AppRoutes.dashboard);
  });

  test('LoginGuard.redirect → null when no session user', () {
    final session = _makeSession(user: null);
    Get.put<AuthSession>(session, permanent: true);

    final guard = LoginGuard();
    final result = guard.redirect(AppRoutes.login);

    expect(result, isNull);
  });
}
