import 'package:get/get.dart';

class DashController extends GetxController {
  final selectedIndex = 0.obs;
  final List<Map<String, String>> popularCourses = [
    {'title': 'Flutter Foundations', 'instructor': 'Alice Johnson'},
    {'title': 'Dart for Beginners', 'instructor': 'Bob Smith'},
    {'title': 'UI/UX Design Principles', 'instructor': 'Carol White'},
    {'title': 'State Management Deep Dive', 'instructor': 'David Lee'},
    {'title': 'Building Responsive Apps', 'instructor': 'Eva Martinez'},
    {'title': 'Firebase Integration', 'instructor': 'Frank Brown'},
  ];

  final List<Map<String, String>> recommendedCourses = [
    {'title': 'Advanced Flutter Patterns', 'instructor': 'Grace Taylor'},
    {'title': 'Clean Architecture in Dart', 'instructor': 'Henry Wilson'},
    {'title': 'Mobile App Security', 'instructor': 'Ivy Anderson'},
    {'title': 'Animations in Flutter', 'instructor': 'Jack Thomas'},
    {'title': 'Testing Flutter Apps', 'instructor': 'Karen Jackson'},
  ];

  final List<Map<String, String>> newCourses = [
    {'title': 'Intro to Riverpod', 'instructor': 'Liam Harris'},
    {'title': 'BLoC Pattern Mastery', 'instructor': 'Mia Clark'},
    {'title': 'Flutter for Web', 'instructor': 'Noah Lewis'},
    {'title': 'Custom Paint & Canvas', 'instructor': 'Olivia Walker'},
    {'title': 'Performance Optimization', 'instructor': 'Paul Hall'},
    {'title': 'App Deployment Strategies', 'instructor': 'Quinn Allen'},
  ];

  void changePage(int index) {
    selectedIndex.value = index;
  }
}
