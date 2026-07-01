import 'package:get/get.dart';
import 'package:appex/app/routes/app_routes.dart';
import 'package:appex/modules/splash/splash_screen.dart';
import 'package:appex/modules/splash/splash_binding.dart';
import 'package:appex/modules/auth/auth_screen.dart';
import 'package:appex/modules/auth/auth_binding.dart';
import 'package:appex/modules/dashboard/dash_screen.dart';
import 'package:appex/modules/dashboard/dash_binding.dart';
import 'package:appex/modules/courses/course_detail_screen.dart';
import 'package:appex/modules/courses/course_binding.dart';
import 'package:appex/modules/profile/profile_screen.dart';
import 'package:appex/modules/profile/profile_binding.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const AuthScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashScreen(),
      binding: DashBinding(),
    ),
    GetPage(
      name: AppRoutes.courseDetail,
      page: () => const CourseDetail(),
      binding: CourseBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
  ];
}
