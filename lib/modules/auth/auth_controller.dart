import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/either.dart';
import '../../core/errors/failures.dart';
import '../../core/unit.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/auth_usecases.dart';
import 'auth_session.dart';

class AuthController extends GetxController {
  AuthController({
    required this.login,
    required this.register,
    required this.logout,
    required this.session,
  });

  final LoginUseCase login;
  final RegisterUseCase register;
  final LogoutUseCase logout;
  final AuthSession session;

  final isLogged = false.obs;
  final currentUser = Rxn<User>();

  final email = ''.obs;
  final displayName = ''.obs;
  final password = ''.obs;
  final isPasswordVisible = false.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  bool isRegistered = false;

  bool get isEmailValid =>
      email.value.contains('@') && email.value.contains('.');
  bool get isPasswordValid => password.value.length >= 6;
  bool get isFormValid =>
      isEmailValid && isPasswordValid && email.value.trim().isNotEmpty;

  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  void switchToRegister() {
    isRegistered = !isRegistered;
    errorMessage.value = null;
    update();
  }

  Future<void> submit() async {
    if (isRegistered) {
      await doRegister();
    } else {
      await doLogin();
    }
  }

  Future<void> doLogin() async {
    errorMessage.value = null;
    isLoading.value = true;
    final result = await login(
      email: email.value,
      password: password.value,
    );
    isLoading.value = false;
    result.fold(
      _onFailure,
      (user) {
        session.setUser(user);
        currentUser.value = user;
        isLogged.value = true;
        Get.offAllNamed(AppRoutes.dashboard);
      },
    );
  }

  Future<void> doRegister() async {
    errorMessage.value = null;
    isLoading.value = true;
    final result = await register(
      email: email.value,
      password: password.value,
      displayName: displayName.value.isEmpty
          ? email.value.split('@').first
          : displayName.value,
    );
    isLoading.value = false;
    result.fold(
      _onFailure,
      (user) {
        session.setUser(user);
        currentUser.value = user;
        isLogged.value = true;
        Get.offAllNamed(AppRoutes.dashboard);
      },
    );
  }

  Future<void> doLogout() async {
    isLoading.value = true;
    final Either<Failure, Unit> result = await logout();
    isLoading.value = false;
    result.fold(_onFailure, (_) {
      session.clear();
      currentUser.value = null;
      isLogged.value = false;
      Get.offAllNamed(AppRoutes.login);
    });
  }

  void _onFailure(Failure failure) {
    errorMessage.value = failure.message;
  }
}
