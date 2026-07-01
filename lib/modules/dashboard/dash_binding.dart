import 'package:get/get.dart';
import 'package:appex/modules/dashboard/dash_controller.dart';

class DashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashController>(() => DashController());
  }
}
