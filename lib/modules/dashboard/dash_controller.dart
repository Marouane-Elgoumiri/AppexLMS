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

  /// Sprint 5 — category-filtered view, populated when a non-'All' chip is
  /// selected. Empty when `category.value.isEmpty` (i.e., 'All').
  final filteredCourses = <Course>[].obs;

  /// True while a category filter fetch is in flight (separate from
  /// `isLoading` so initial-load spinner and filter spinner don't fight
  /// over the same indicator).
  final isFiltering = false.obs;

  final RxnString filterError = RxnString();

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

  /// Sprint 5 — selecting a chip now triggers a real filtered fetch:
  /// 'All' (empty string) clears the filter and restores the carousels;
  /// any other category swaps the dashboard into filtered-list mode.
  Future<void> setCategory(String cat) async {
    category.value = cat;
    if (cat.isEmpty) {
      // 'All' — restore the carousel view.
      filteredCourses.clear();
      filterError.value = null;
      return;
    }
    isFiltering.value = true;
    filterError.value = null;
    final result = await getByCategory(cat);
    isFiltering.value = false;
    result.fold(
      (failure) {
        filterError.value = failure.message;
        filteredCourses.clear();
      },
      (list) => filteredCourses.assignAll(list),
    );
  }

  /// True when the dashboard should render the filtered list view (vs the
  /// 'All' carousel trio). Reactive via [category].
  bool get isFilteringActive => category.value.isNotEmpty;

  Future<void> refreshDashboard() async {
    final String activeCategory = category.value;
    if (activeCategory.isEmpty) {
      isLoading.value = true;
    } else {
      isFiltering.value = true;
    }
    errorMessage.value = null;
    filterError.value = null;

    final result = activeCategory.isEmpty
        ? await getCourses()
        : await getByCategory(activeCategory);

    if (activeCategory.isEmpty) {
      isLoading.value = false;
    } else {
      isFiltering.value = false;
    }
    lastRefresh.value = DateTime.now();

    result.fold(
      (failure) {
        if (activeCategory.isEmpty) {
          errorMessage.value = failure.message;
        } else {
          filterError.value = failure.message;
          filteredCourses.clear();
        }
      },
      (list) {
        if (activeCategory.isEmpty) {
          allCourses.assignAll(list);
          splitCarousels(list);
        } else {
          filteredCourses.assignAll(list);
        }
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
