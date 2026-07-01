import 'package:get/get.dart';

class AuthController extends GetxController {
  final isLogged = false.obs;

  void login() {
    isLogged.value = true;
    Get.offAllNamed('/dashboard');
  }

  void logout() {
    isLogged.value = false;
    Get.offAllNamed('/login');
  }
}
