import 'package:get/get.dart';

import '../../domain/usecases/auth/auth_usecases.dart';
import 'auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginUseCase>(() => LoginUseCase(Get.find()), fenix: true);
    Get.lazyPut<RegisterUseCase>(
      () => RegisterUseCase(Get.find()),
      fenix: true,
    );
    Get.lazyPut<LogoutUseCase>(() => LogoutUseCase(Get.find()), fenix: true);
    Get.lazyPut<AuthController>(
      () => AuthController(
        login: Get.find(),
        register: Get.find(),
        logout: Get.find(),
      ),
    );
  }
}
