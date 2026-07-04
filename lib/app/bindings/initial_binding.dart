import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/network/http_client.dart';
import '../../data/datasources/mock/mock_course_data_source.dart';
import '../../data/datasources/mock/mock_enrollment_data_source.dart';
import '../../data/datasources/mock/mock_lesson_data_source.dart';
import '../../data/datasources/mock/mock_user_data_source.dart';
import '../../data/datasources/remote/number_trivia_remote_data_source.dart';
import '../../data/datasources/remote/supabase/supabase_course_data_source.dart';
import '../../data/datasources/remote/supabase/supabase_enrollment_data_source.dart';
import '../../data/datasources/remote/supabase/supabase_lesson_data_source.dart';
import '../../data/datasources/remote/supabase/supabase_user_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../data/repositories/enrollment_repository_impl.dart';
import '../../data/repositories/lesson_repository_impl.dart';
import '../../data/repositories/number_trivia_repository_impl.dart';
import '../../data/repositories/supabase/supabase_auth_repository_impl.dart';
import '../../data/repositories/supabase/supabase_course_repository_impl.dart';
import '../../data/repositories/supabase/supabase_enrollment_repository_impl.dart';
import '../../data/repositories/supabase/supabase_lesson_repository_impl.dart';
import '../../data/repositories/supabase/supabase_user_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/course_repository.dart';
import '../../domain/repositories/enrollment_repository.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../../domain/repositories/number_trivia_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../env.dart';

/// Wires up the entire data layer at app start.
///
/// Branches on [useSupabase] (compile-time `--dart-define=USE_SUPABASE=false`
/// to fall back to mocks). Either way only ONE set of repos is registered —
/// `Get.find<X>()` always resolves to the active variant.
///
/// Sprint 4a: Supabase (default)
/// Sprint 4b: swap to MongoDB by adding a third branch and toggling which
///           impl factory lines are wrapped in `if (useSupabase) { ... }`.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // ── Always-on wiring ────────────────────────────────────────────────
    final httpClient = HttpClient()
      ..configure(baseUrl: 'https://numbersapi.com');
    Get.put<HttpClient>(httpClient, permanent: true);

    Get.put<NumberTriviaRemoteDataSource>(
      NumberTriviaRemoteDataSourceImpl(),
      permanent: true,
    );
    Get.put<NumberTriviaRepository>(
      NumberTriviaRepositoryImpl(remote: Get.find()),
      permanent: true,
    );

    // ── LMS data sources + repos: chosen by [useSupabase] ───────────────
    if (useSupabase) {
      _bindSupabase();
    } else {
      _bindMock();
    }
  }

  void _bindSupabase() {
    // Defensive: callers may not have run `Supabase.initialize()` (e.g.
    // widget tests, hot-reload scenarios). The Supabase SDK's `instance`
    // getter asserts when not initialized, so probe it via a guarded try/
    // catch and fall through to the mock wiring if missing.
    try {
      Supabase.instance.isInitialized; // lazy: read the static field only.
      // ignore: avoid_print
      assert(true);
    } catch (_) {
      _warn(
        'Supabase is not initialized; falling back to mock bindings. '
        'Call Supabase.initialize in main() to use real backend.',
      );
      _bindMock();
      return;
    }

    final client = Supabase.instance.client;

    // Data sources
    Get.put<CourseDataSource>(
      SupabaseCourseDataSource(client: client),
      permanent: true,
    );
    Get.put<LessonDataSource>(
      SupabaseLessonDataSource(client: client),
      permanent: true,
    );
    Get.put<EnrollmentDataSource>(
      SupabaseEnrollmentDataSource(client: client),
      permanent: true,
    );
    Get.put<UserDataSource>(
      SupabaseUserDataSource(client: client),
      permanent: true,
    );

    // Repositories
    Get.put<CourseRepository>(
      SupabaseCourseRepositoryImpl(dataSource: Get.find()),
      permanent: true,
    );
    Get.put<LessonRepository>(
      SupabaseLessonRepositoryImpl(dataSource: Get.find()),
      permanent: true,
    );
    Get.put<EnrollmentRepository>(
      SupabaseEnrollmentRepositoryImpl(dataSource: Get.find()),
      permanent: true,
    );
    Get.put<UserRepository>(
      SupabaseUserRepositoryImpl(dataSource: Get.find()),
      permanent: true,
    );
    Get.put<AuthRepository>(
      SupabaseAuthRepositoryImpl(client: client),
      permanent: true,
    );
  }

  void _warn(String message) {
    // ignore: avoid_print
    print('⚠️  InitialBinding: $message');
  }

  void _bindMock() {
    // Sprint 3 mock wiring — preserved verbatim so toggling
    // --dart-define=USE_SUPABASE=false gives us a fully-offline demo.
    final mockUser = MockUserDataSource();
    Get.put<MockUserDataSource>(mockUser, permanent: true);
    Get.put<CourseDataSource>(MockCourseDataSource(), permanent: true);
    Get.put<LessonDataSource>(MockLessonDataSource(), permanent: true);
    Get.put<EnrollmentDataSource>(
      InMemoryEnrollmentDataSource(),
      permanent: true,
    );

    Get.put<CourseRepository>(
      CourseRepositoryImpl(dataSource: Get.find()),
      permanent: true,
    );
    Get.put<LessonRepository>(
      LessonRepositoryImpl(dataSource: Get.find()),
      permanent: true,
    );
    Get.put<EnrollmentRepository>(
      EnrollmentRepositoryImpl(dataSource: Get.find()),
      permanent: true,
    );
    Get.put<UserRepository>(
      UserRepositoryImpl(dataSource: mockUser),
      permanent: true,
    );
    Get.put<AuthRepository>(
      AuthRepositoryImpl(userDataSource: mockUser),
      permanent: true,
    );
  }
}
