import 'package:get/get.dart';

import '../../domain/repositories/course_repository.dart';
import '../../domain/usecases/auth/auth_usecases.dart';
import '../../domain/usecases/enrollments/enroll_in_course.dart';
import '../../domain/usecases/user/get_current_user.dart';
import 'profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GetCurrentUser>(
      () => GetCurrentUser(Get.find()),
      fenix: true,
    );
    Get.lazyPut<GetEnrollmentsForUser>(
      () => GetEnrollmentsForUser(Get.find()),
      fenix: true,
    );
    Get.lazyPut<LogoutUseCase>(() => LogoutUseCase(Get.find()), fenix: true);

    Get.lazyPut<ProfileController>(
      () => ProfileController(
        getCurrentUser: Get.find(),
        getEnrollmentsForUser: Get.find(),
        logoutUseCase: Get.find(),
        courseRepository: Get.find<CourseRepository>(),
      ),
    );
  }
}
