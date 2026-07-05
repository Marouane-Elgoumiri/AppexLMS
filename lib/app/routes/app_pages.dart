import 'package:get/get.dart';

import 'app_routes.dart';
import 'auth_guard.dart';
import '../../modules/splash/splash_screen.dart';
import '../../modules/splash/splash_binding.dart';
import '../../modules/auth/auth_screen.dart';
import '../../modules/auth/auth_binding.dart';
import '../../modules/dashboard/dash_screen.dart';
import '../../modules/dashboard/dash_binding.dart';
import '../../modules/courses/course_detail_screen.dart';
import '../../modules/courses/course_binding.dart';
import '../../modules/profile/profile_screen.dart';
import '../../modules/profile/profile_binding.dart';
import '../../modules/number_trivia/number_trivia_screen.dart';
import '../../modules/number_trivia/number_trivia_binding.dart';

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
      middlewares: [LoginGuard()],
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashScreen(),
      binding: DashBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.courseDetail,
      page: () => const CourseDetail(),
      binding: CourseBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.numberTrivia,
      page: () => const NumberTriviaScreen(),
      binding: NumberTriviaBinding(),
      middlewares: [AuthGuard()],
    ),
  ];
}
