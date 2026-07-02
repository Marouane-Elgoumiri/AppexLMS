import 'package:get/get.dart';

class AuthController extends GetxController {
  final isLogged = false.obs;

  final email = ''.obs;
  final password = ''.obs;
  final isPasswordVisible = false.obs;
  final isLoading = false.obs;

  // GetBuilder state (page-level)
  bool isRegistered = false;

  // Validation - used by Obx
  bool get isEmailValid => 
    email.value.contains('@') && email.value.contains('.') ;
  bool get isPasswordValid => 
    password.value.length >= 6;
  bool get isFormValid => isEmailValid && isPasswordValid;

  // Methods
  void togglePasswordVisibility() => isPasswordVisible.value = !isPasswordVisible.value;

  Future<void> login() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
    isLogged.value = true;
    Get.offAllNamed('/dashboard');
  }
  Future<void> switchToRegister() async {
    isRegistered = !isRegistered;
    update(); // Notify GetBuilder to rebuild the UI
  }
  Future<void> register() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
    isLogged.value = true;
    Get.offAllNamed('/dashboard');
  }
  Future<void> logout() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
    isLogged.value = false;
    Get.offAllNamed('/login');
  }
}
