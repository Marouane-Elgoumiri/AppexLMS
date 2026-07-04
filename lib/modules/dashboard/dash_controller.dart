import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/env.dart';
import '../../domain/entities/course.dart';
import '../../domain/usecases/courses/get_courses.dart';

class DashController extends GetxController {
  DashController({
    required this.getCourses,
    required this.getByCategory,
  });

  final GetCourses getCourses;
  final GetCoursesByCategory getByCategory;

  final selectedIndex = 0.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final category = ''.obs;
  final lastRefresh = DateTime.now().obs;

  final allCourses = <Course>[].obs;
  final popularCourses = <Course>[].obs;
  final recommendedCourses = <Course>[].obs;
  final newCourses = <Course>[].obs;

  static const int _popularTake = 5;
  static const int _recommendedTake = 5;
  static const int _newTake = 5;

  /// Held so we can dispose it in [onClose]. Null in the mock-mode build.
  dynamic _courseChangesChannel;

  @override
  void onInit() {
    super.onInit();
    refreshDashboard();
    if (useSupabase) {
      _subscribeToCourseUpdates();
    }
  }

  @override
  void onClose() {
    if (_courseChangesChannel != null) {
      // ignore: undefined_identifier
      try {
        // The Supabase channel API lives on `Supabase.instance.client.realtime`.
        Supabase.instance.client.removeChannel(_courseChangesChannel);
      } catch (_) {}
    }
    super.onClose();
  }

  /// Restream courses whenever `public.courses` rows UPDATE. Refreshes the
  /// obvious local lists (covers UI state) plus surfaces a SnackBar.
  void _subscribeToCourseUpdates() {
    final client = Supabase.instance.client;
    _courseChangesChannel = client
        .channel('appex:public.courses:updates')
        .onPostgresChanges(
          schema: 'public',
          table: 'courses',
          event: PostgresChangeEvent.update,
          callback: (_) {
            // Re-fetch + show a SnackBar only if this controller is
            // mounted (we might be unmounted mid-update).
            if (isClosed) return;
            refreshDashboard();
            _snackBar('Courses updated', 'Dashboard refreshed.');
          },
        )
        .subscribe();
  }

  void _snackBar(String title, String body) {
    // use Get's local cache for a quick, dependency-free toast.
    if (Get.isRegistered<GetMaterialController>()) {
      Get.snackbar(title, body, snackPosition: SnackPosition.BOTTOM);
    }
  }

  void changePage(int index) => selectedIndex.value = index;

  void setCategory(String cat) => category.value = cat;

  Future<void> refreshDashboard() async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await getCourses();
    isLoading.value = false;
    lastRefresh.value = DateTime.now();

    result.fold(
      (failure) => errorMessage.value = failure.message,
      (list) {
        allCourses.assignAll(list);
        splitCarousels(list);
      },
    );
  }

  void splitCarousels(List<Course> list) {
    if (list.isEmpty) {
      popularCourses.clear();
      recommendedCourses.clear();
      newCourses.clear();
      return;
    }
    final shuffled = [...list]..shuffle();
    popularCourses.assignAll(
      shuffled.take(_popularTake).toList(growable: false),
    );
    recommendedCourses.assignAll(
      list.take(_recommendedTake).toList(growable: false),
    );
    newCourses.assignAll(
      list.reversed.take(_newTake).toList(growable: false),
    );
  }
}
