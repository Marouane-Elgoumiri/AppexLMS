# AppexLMS — Sprint Tracker

## Sprint Overview

| Sprint | Phase | Duration | Status |
|--------|-------|----------|--------|
| 0 | Project Setup & Architecture Foundation | Week 1 | ✅ Completed |
| 1 | UI Foundations — Netflix-Inspired Dashboard | Week 2-3 | ✅ Completed |
| 2 | State Management with GetX | Week 4 | ✅ Completed |
| 3 | Data Layer — Clean Architecture | Week 5 | ✅ Completed |
| 4a | Database — Supabase/PostgreSQL CRUD | Week 6-7 | ✅ Code Completed — `db push` pending |
| 4b | Database — MongoDB Comparison | Week 8 | Not Started |
| 5 | Feature Modules — Full Integration | Week 9-10 | Not Started |
| 6 | Polish & Best Practices | Week 11 | Not Started |

---

## Sprint 0: Project Setup & Architecture Foundation

**Goal:** Scaffold the project, configure dependencies, establish architecture patterns.

**Concepts:** Imperative vs Declarative, Clean Flutter Architecture

### Tasks

- [x] Create Flutter project and set up folder structure (app/, data/, domain/, modules/)
- [x] Install GetX and configure initial setup
- [x] Set up Supabase project (free tier) and configure client
- [x] Define AppTheme with even-number spacing scale
- [x] Set up GetX routing and initial bindings
- [x] Create placeholder screens for all modules

### Key Learnings

- Imperative vs Declarative: Flutter rebuilds the entire widget subtree on state change (declarative), vs manually mutating DOM elements (imperative)
- Clean Architecture layers: Presentation → Domain ← Data (domain has no dependencies)
- `get` is a runtime dependency — goes in `dependencies`, not `dev_dependencies`
- Supabase `anonKey` deprecated → use `publishableKey`
- GetX bindings: `Get.lazyPut` for lazy injection, `Get.put` for eager (e.g., splash controller)

### Key Fixes Applied

- Moved `get` from dev_dependencies to dependencies
- Fixed `pubspec.yaml` `assets:` indentation (must be under `flutter:` block)
- Replaced deprecated `surfaceVariant` with `surfaceContainerHighest` across app
- Replaced deprecated `colorScheme.background` with `colorScheme.surface`
- Class name mismatch: `DashboardScreen` → `DashScreen` in app_pages.dart

### Completion Criteria

- [x] `flutter run` launches app with placeholder screens
- [x] Folder structure matches architecture spec
- [x] GetX navigation works between placeholder screens

---

## Sprint 1: UI Foundations — Netflix-Inspired Dashboard

**Goal:** Build static Netflix-style UI with proper layout discipline.

**Concepts:** Rows & Columns, Expanded/Flexible, Even-number dimensions, Responsive layout

### Tasks

- [x] Design and build Splash Screen — auto-navigates to login after 2s
- [x] Design and build Login Screen with overflow protection, logo, email/password fields, login/signup buttons
- [x] Build Dashboard hero banner section — gradient overlay, featured course, Continue button
- [x] Build horizontal course carousel rows — Netflix-style scrollable rows
- [x] Build Dashboard with three CourseCarousel rows (Continue Learning, Popular, New Releases)
- [x] Build bottom navigation bar (Home, Search, Profile)
- [x] Enforce even-number dimension convention across all screens using AppSpacing
- [x] Use SingleChildScrollView with LayoutBuilder for responsive overflow protection
- [x] Refactor DashScreen from StatefulWidget to GetView<DashController> (preview of Sprint 2)
- [x] Wire AuthScreen Login button to AuthController.login()

### Key Learnings

- `Expanded` fills remaining space (forces size), `Flexible` wraps content but can grow
- Even-number convention: base unit 4px, all padding/margin/sizing use multiples of 4
- Netflix layout pattern: Column → Hero + multiple horizontal ListView.builder rows
- SingleChildScrollView + LayoutBuilder for overflow-safe layouts on small devices
- `BoxFit.contain` for logos (preserves aspect ratio), `BoxFit.cover` for thumbnails (fills space)
- `GetView<TController>` auto-wires controllers into screens without boilerplate
- 3 reusable dashboard widgets extracted: HeroBanner, CourseCarousel, CourseCard

### Key Fixes Applied

- Renamed deprecated `surfaceVariant` → `surfaceContainerHighest` across AppColors, AppTheme, CourseCard, HeroBanner
- Replaced deprecated `colorScheme.background` → `colorScheme.surface` in HeroBanner
- Replaced `Colors.blue` → `AppColors.primary` for color consistency
- Replaced `BoxFit.cover` → `BoxFit.contain` on AuthScreen logo to prevent cropping
- Fixed `DashboardScreen` class name mismatch → `DashScreen` in app_pages.dart
- Fixed `__` unnecessary underscores in CourseCarousel
- All hardcoded dimensions (152, 200, 120, 8, 4, 224, 16, 200, 24) replaced with AppSpacing constants
- **Dashboard overflow (56px)**: Buggy math `AppSpacing.xxxl * AppSpacing.xs` produced 480px carousel row height. Replaced with explicit named constants (`CourseCard.cardHeight = 200`, `HeroBanner.bannerHeight = 200`). Lesson: never multiply spacing constants to compose widget sizes — declare explicit dimensions per widget

### Key Review Session Findings (Definition of Done)

- HeroBanner properly gradient-styled, title/instructor fit, Continue button wired
- CourseCarousel height now equals `CourseCard.cardHeight` — perfect vertical alignment, no internal overflow
- CourseCard uses `Flexible` around title text to handle 2-line titles gracefully
- All `BoxFit` choices reviewed: `contain` for logos (no crop), `cover` for thumbnails (fills space)
- All theme references use `colorScheme.*` and `textTheme.*` — no direct hex/Color calls in widgets
- `flutter analyze` — 0 issues
- `flutter test` — all passed

### Completion Criteria

- [x] All screens render correctly on multiple device sizes
- [x] No hardcoded odd-number dimensions in UI code
- [x] Expanded/Flexible used correctly (no overflow errors)
- [x] `flutter analyze` — 0 issues
- [x] `flutter test` — all tests passed

---

## Sprint 2: State Management with GetX

**Goal:** Add reactive state management to existing UI screens.

**Concepts:** GetxController, GetBuilder, .obs, Obx

### Tasks

- [x] Create `AuthController` (GetxController) with GetBuilder pattern
- [x] Refactor `AuthController` to also use .obs + Obx pattern (side by side comparison)
- [x] Create `DashboardController` — manage course categories, featured courses
- [x] Create `CourseController` — manage course list, filters
- [x] Set up GetX Bindings for dependency injection
- [x] Wire controllers to existing UI screens

### Key Learnings

- `GetBuilder` + `update()`: Manual, imperative-style updates. Call `update()` when you want to rebuild. Good for infrequent updates, less overhead.
- `.obs` + `Obx`: Reactive, declarative-style. Auto-rebuilds when value changes. Good for form validation, counters, toggles.
- Rule of thumb: Use GetBuilder for page-level state, Obx for fine-grained reactive widgets
- **Obx gotcha:** every `Obx` builder function must directly read at least one `.obs` value; otherwise GetX throws "improper use of a GetX has been detected" (e.g. wrapping a `ListView` of independently-reactive chips in a parent `Obx` that reads nothing — drop the wrapper).

### Key Fixes Applied

- Replaced raw `Future.delayed`-stubbed `login()/register()/logout()` with calls to a (mock) repository through use cases (follow-up during Sprint 3).
- Hard-coded `Map<String, String>` course lists replaced with `Course` entities flowing from the data layer (Sprint 3).

### Completion Criteria

- [x] Login form shows reactive validation with Obx
- [x] Dashboard loads course data through controller
- [x] GetX bindings inject controllers correctly
- [x] Student can explain GetBuilder vs Obx difference

---

## Sprint 3: Data Layer — Clean Architecture

**Goal:** Separate data logic from controllers using the repository pattern, and introduce a Number Trivia sandbox to practice clean architecture end-to-end.

**Concepts:** Repository pattern, Domain entities, Data models, Dependency inversion, Use cases, Either/Failure, GetX DI

### Tasks

- [x] Add `dio: ^5.5.4+1` and `equatable: ^2.0.5` to `pubspec.yaml`
- [x] Add cross-cutting `lib/core/`: `errors/{failures,exceptions}.dart`, `network/http_client.dart`, `either.dart` (minimalist sealed `Left|Right`), `unit.dart`
- [x] Define domain entities: `User`, `Course`, `Lesson`, `Enrollment`, `NumberTrivia` (all `Equatable`, no Flutter / no JSON)
- [x] Define abstract repository interfaces in `domain/repositories/` (6 interfaces)
- [x] Implement use cases as separate classes in `domain/usecases/` (`LoginUseCase`, `RegisterUseCase`, `LogoutUseCase`, `GetCourses`, `GetCoursesByCategory`, `GetCourseById`, `GetLessonsForCourse`, `EnrollInCourse`, `GetEnrollmentsForUser`, `GetConcreteNumberTrivia`, `GetRandomNumberTrivia`)
- [x] Create data models with `fromJson`/`toJson`/`toEntity` (`UserModel`, `CourseModel`, `LessonModel`, `EnrollmentModel`, `NumberTriviaModel`)
- [x] Implement data sources: `NumberTriviaRemoteDataSource` (Dio → numbersapi.com) + `MockCourseDataSource`, `MockLessonDataSource`, `MockUserDataSource`, `InMemoryEnrollmentDataSource`
- [x] Implement concrete repositories in `data/repositories/` returning `Either<Failure, T>` (no throws)
- [x] Wire app-wide singletons in `InitialBinding` (HttpClient, data sources, repositories)
- [x] Wire per-use-case dependencies in module bindings (auth, dashboard, courses, number trivia)
- [x] Refactor `AuthController`, `DashController`, `CourseController` to receive use cases via constructor (no `Get.find()` inside controllers)
- [x] Build Number Trivia feature module: controller + binding + screen + `TriviaCard` widget + route (`/number-trivia`)
- [x] Add "Try the Number Trivia demo" link on AuthScreen
- [x] Write unit tests: 4 entity↔model mapping tests (3.1–3.4), `MockUserRepository` CRUD (3.5), NumberTrivia data source / repository / use case tests
- [x] `flutter analyze` — 0 issues
- [x] `flutter test` — 27 tests passing

### Key Learnings

- **Entity (domain) vs Model (data):** Entity is pure Dart, immutable, `Equatable`. Model extends the entity and adds `fromJson`/`toJson`/`toEntity`. The data layer knows about JSON; the domain layer never does.
- **Dependency Inversion:** Repository interface lives in `domain/repositories/` (abstract), implementation lives in `data/repositories/` (concrete). Controllers depend on the abstract interface, GetX bindings wire the concrete impl behind the interface — so swapping data sources (Sprint 4a vs 4b) only touches `data/`.
- **Use cases as single-purpose classes:** Each business action is a class with a single `call()` method (Dart's `call` lets you invoke `useCase(args)`). Use cases orchestrate one or more repositories; they don't know how data is fetched.
- **`Either<Failure, T>` instead of throws:** Repositories return `Right(value)` on success or `Left(Failure)` on error. Controllers `result.fold(onFailure, onSuccess)` — no try/catch, type-safe error handling. Implemented as a 20-line sealed `Either` instead of pulling in `dartz` to keep the dependency surface lean.
- **GetX DI patterns:** `Get.put` (eager, `permanent: true`) for app-wide singletons in `InitialBinding`; `Get.lazyPut` + `fenix: true` for use cases (cleared and re-created as needed, but re-instantiable on revisit); `Get.lazyPut` (no fenix) for controllers tied to a route.
- **`Get.lazyGet` does not exist** — only `Get.lazyPut` does. Use `Get.lazyPut<T>(() => T(Get.find()))` for lazy registration.
- **Constructor injection over service-locator lookups:** Controllers declare their use cases in the constructor (`AuthController({required this.login, ...})`); the binding wires them. This makes controllers testable without GetX and keeps coupling explicit. Avoid `Get.find()` *inside* controller bodies; only call it in `Bindings.dependencies`.

### Number Trivia Sandbox

- **Data source: bundled fact table** (the original `https://numbersapi.com` is hijacked as of 2024 — a parking page returns 404 for every path; rapid alternative mirrors like `numbersapi.duckdns.org` return `NXDOMAIN` and ~10 other public mirrors are dead/parked/disabled — only the RapidAPI-hosted paid tier is still alive). To keep the sandbox self-contained and remote-failure-free, `NumberTriviaRemoteDataSourceImpl` now serves ~30 curated facts for known numbers + a generic fallback pool for unknowns, with simulated 300 ms latency so the loading state still gets exercised. The interface name is preserved so Sprint 4a can swap to a Dio-backed or Supabase-backed impl in one binding line.
- Flow demonstrated: `NumberTriviaScreen → NumberTriviaController → GetConcreteNumberTrivia → NumberTriviaRepository → NumberTriviaRemoteDataSource → NumberTriviaModel.fromRawText → NumberTrivia entity`.
- Errors surface as a typed `ServerFailure.message` shown in red on the screen (no throw paths exist in the bundled impl, but the contract still holds — and the repository still wraps any future data source's throws into typed Failures).

### Key Fixes / Decisions

- Removed `@override` on `toEntity()` in model classes — entities don't declare `toEntity`, so the annotation was invalid.
- Moved `Unit` out of `enrollment_repository.dart` into `lib/core/unit.dart` so multiple layers can import it without circular dependencies.
- Refactored `CourseCarousel` from `List<dynamic>` to `List<Course>` and added an `onTap` callback; `CourseCard` gained an optional `category` placeholder and an `InkWell` if `onTap` is non-null.
- `CourseController` now reads `Get.arguments` (`Course` entity or `String` id) in `onInit` instead of being told to load `'some-id'` directly from `build()` — eliminating the `addPostFrameCallback` re-fire bug from Sprint 2.

### Completion Criteria

- [x] Domain entities have no external dependencies (no Flutter, no Dio, no JSON imports)
- [x] Repository interfaces are abstract classes in `domain/repositories/`
- [x] Controllers receive use cases via DI (constructor injection, no `Get.find()` inside controller bodies)
- [x] App works with mock data provider for all LMS entities; Number Trivia hits the real public API over Dio
- [x] Errors are surfaced as typed `Failure`s, not exceptions, across the controller/repository boundary

---

## Sprint 4a: Database — Supabase/PostgreSQL CRUD

**Goal:** Connect to Supabase and implement full CRUD operations.

**Concepts:** SQL schema design, Supabase SDK, CRUD patterns, Row Level Security, real-time subscriptions, dependency inversion (mock ↔ remote swap)

### Tasks

- [x] Add `mocktail`, `integration_test`, `shared_preferences` to dev_dependencies
- [x] `supabase init` to scaffold `supabase/` folder
- [x] Author migration `supabase/migrations/0001_init_schema.sql` — `profiles`, `courses`, `lessons`, `enrollments` (column names match the existing Dart model JSON contracts; `"order"` quoted because it's a reserved word; `completed_lesson_ids text[]` keeps `EnrollmentModel.fromJson` happy without reshaping)
- [x] Author migration `0002_rls_policies.sql` — RLS on all tables; `enrollments` and `profiles` are user-scoped; `courses`/`lessons` readable by any authenticated user; `on_auth_user_created` trigger auto-creates a `profiles` row on signup
- [x] Author migration `0003_seed.sql` — idempotent seeds for the 8 courses + 5 lessons per course (mirrors Sprint 3 mocks). **Demo auth user is NOT seeded here**: see the `seed_demo_user.sh` task below for why direct `auth.users` INSERTs are unsafe.
- [x] Author migration `0004_progress_helper.sql` — `mark_lesson_completed(uuid, text)` SECURITY DEFINER RPC, grants `execute` only to `authenticated`
- [ ] **`supabase db push`** (blocker: requires `supabase login` + `supabase link` on this machine)
- [x] Implement Supabase data sources: `SupabaseCourseDataSource`, `SupabaseLessonDataSource`, `SupabaseEnrollmentDataSource`, `SupabaseUserDataSource`
- [x] Implement Supabase repository impls: `SupabaseCourse/Lesson/Enrollment/User/AuthRepositoryImpl` (each maps `ServerException`/`CacheException`/`PostgrestException`/`AuthException` → typed `Failure`)
- [x] `SupabaseAuthRepositoryImpl` speaks directly to `supabase.auth.signInWithPassword/signUp/signOut` (no data source layer — auth is a service)
- [x] Add runtime-flag: `lib/app/env.dart` exposes `const useSupabase` (defaults true, override via `--dart-define=USE_SUPABASE=false`)
- [x] Wire `InitialBinding` to branch on `useSupabase`; mock wiring preserved verbatim
- [x] Add real-time subscription: `DashController.onInit()` subscribes to `public.courses` UPDATE; `onClose()` removes the channel
- [x] Defensive: `InitialBinding` falls back to mocks if `Supabase.initialize` was not called (assertion in `Supabase.instance` is caught)
- [x] Add rotation note to `supabase_config.dart` (the publishable key should be rotated pre-deployment)
- [x] Tests: 6 course-repo + 3 lesson-repo + 5 enrollment-repo + 4 user-repo + 5 auth-repo + 2 realtime-wiring unit tests; widget test now mocks `Supabase.initialize` for headless runs
- [x] `scripts/verify_rls.sh` — curl smoke-test for RLS criterion 4a.8 (self-OK, other-user-`[]`, anon-`[]`)
- [x] `scripts/seed_demo_user.sh` — service-role admin script that creates the demo user (`student@appex.dev` / `password123`) via `supabase.auth.admin.createUser`, idempotently upserts the matching `profiles` row, and creates a pre-enrollment in Flutter Foundations. Replaces the previous (broken) approach of inserting directly into `auth.users` from a SQL migration
- [x] `flutter analyze` — 0 issues
- [x] `flutter test` — 52 of 52 tests passing (Sprint 3's 27 still green; 25 new for Sprint 4a)

### Key Learnings

- **Supabase SDK**: `client.from(table).select()` / `.insert(...)` / `.update(...)` / `.eq(col, value)` / `.limit(1)`. Method-chain builders return `Future<T>` directly. Errors surface as `PostgrestException`.
- **RLS** secures data per-user at the database level. Policy: `create policy X on T to authenticated using (auth.uid() = user_id)`. The user can't see other users' rows — verified by `scripts/verify_rls.sh`.
- **`auth.users` vs `profiles`**: Supabase Auth lives in `auth.users` (managed by them, not yours). Public interface (display_name etc.) goes on a separate `public.profiles` table or you read it straight from `auth.user.userMetadata`.
- **Quoted reserved words**: `"order"` must be double-quoted everywhere (DDL, queries, JSON keys remain unquoted because the wire returns `"order"`).
- **`text[]` for course-progress** keeps `EnrollmentModel.fromJson` working unchanged. For atomic idempotent updates use a SECURITY DEFINER RPC (`mark_lesson_completed`) instead of a roundtrip SELECT + UPDATE.
- **Gotcha**: `Supabase.instance` is a `static getter` that **asserts** when not initialized — even just reading the static triggers the assert. There's no safe "is it initialized?" probe, so any "polite fallback" path must `try { Supabase.instance } catch (_)` rather than `if (Supabase.instance.isInitialized)`.
- **Auth not on a data source**: Supabase Auth services (`signInWithPassword`, `signUp`, `signOut`) don't fit a "table-shaped data source" pattern. `SupabaseAuthRepositoryImpl` calls them directly on `client.auth` — `AuthController` still depends only on the abstract `AuthRepository`.
- **Never insert into `auth.users` directly from a migration**. Two reasons observed live during Sprint 4a: (1) GoTrue hashes passwords with **scrypt**, not bcrypt — a precomputed bcrypt hash in `encrypted_password` makes every `/auth/v1/token?grant_type=password` attempt fail with HTTP 500 `{"unexpected_failure","database error querying schema"}`; (2) subsequent GoTrue versions added NOT NULL columns (e.g. `is_sso_user`, `is_anonymous`, `deleted_at`) that direct INSERTs don't populate, so even a successful insert leaves a row GoTrue can't query. The fix is to call `supabase.auth.admin.createUser` over HTTP with the service-role key — GoTrue defines the row and the `on_auth_user_created` trigger from `0002_rls_policies.sql` back-fills `public.profiles`. `scripts/seed_demo_user.sh` does this idempotently.
- **Dependency Inversion payoff**: Sprint 3's mock + Sprint 4a's Supabase repo both implement the same abstract interfaces. Switching is one branch on a const + `InitialBinding` swap — `domain/`, `modules/`, and entity/use-case code are all unchanged.

### Provider Swap Pattern (how to swap mock ↔ Supabase)

Run the app with mocks only:
```bash
flutter run --dart-define=USE_SUPABASE=false
```

Run with Supabase (default):
```bash
flutter run
```

Toggle the wiring in `InitialBinding.dependencies()`:
```dart
if (useSupabase) _bindSupabase();
else              _bindMock();
```

Sprint 4b will add a third branch (`_bindMongo()`, wired to MongoDB data sources) and toggle using a second env flag — only `data/` and `lib/app/bindings/` change. Sprint 4a is the textbook demonstration of how these swaps pay off.

### Pending manual steps (user action required)

1. If the prior `db push` left a malformed `auth.users` row for the demo user, clean it up first (Dashboard → SQL Editor):
   ```sql
   delete from auth.users where id = '11111111-1111-1111-1111-111111111111';
   delete from public.enrollments where user_id = '11111111-1111-1111-1111-111111111111';
   ```
   `ON DELETE CASCADE` removes the matching `profiles` row. Skip if you `supabase db reset --linked` instead.
2. **`supabase login`** in a terminal (paste access token from https://supabase.com/dashboard/account/tokens).
3. **`supabase link --project-ref npqrpcnpgfshazeozmkr`** inside this repo.
4. **`supabase db push`** — applies the remaining migrations. `0003_seed.sql` now seeds only courses + lessons; the demo user is created by the next step.
5. **`./scripts/seed_demo_user.sh`** — set `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` env vars first. Idempotent.
6. (Optional) Run **`bash scripts/verify_rls.sh`** with the env vars set to smoke-test RLS.

### Completion Criteria

- [x] Full CRUD code complete for all entities via Supabase (operations compile and unit-tested; live verification needs the `db push` step above)
- [x] RLS policy SQL authored, ready to deploy
- [x] Real-time subscription wired in `DashController`
- [x] Mock provider can be swapped for Supabase provider via DI (env flag + `InitialBinding` branch)

---

## Sprint 4b: Database — MongoDB Comparison

**Goal:** Implement the same CRUD operations with MongoDB, leveraging Clean Architecture to swap data sources.

**Concepts:** Document vs Relational modeling, MongoDB CRUD, Architecture flexibility

### Tasks

- [ ] Set up MongoDB Atlas cluster (free tier) or Node.js REST API
- [ ] Design document schemas for MongoDB (denormalized vs normalized)
- [ ] Implement MongoDB provider: Users CRUD
- [ ] Implement MongoDB provider: Courses CRUD
- [ ] Implement MongoDB provider: Enrollments & Progress CRUD
- [ ] Swap Supabase repositories for MongoDB repositories (only change data/ layer)
- [ ] Document the swap experience — what changed and what didn't

### Key Learnings

- Document model (MongoDB): embed related data, no JOINs needed for common queries
- Relational model (PostgreSQL): normalize data, use foreign keys and JOINs
- Architecture payoff: Only data/ layer changed. Controllers, domain, and UI stayed the same.

### Completion Criteria

- [ ] Full CRUD works with MongoDB as data source
- [ ] Only data/ layer files were modified
- [ ] Domain entities and controllers are unchanged
- [ ] Comparison notes documented

---

## Sprint 5: Feature Modules — Full Integration

**Goal:** Complete end-to-end feature implementation across all modules.

**Concepts:** All concepts combined — architecture, state management, UI, database

### Tasks

- [x] **Auth Module:** Login/Register → Supabase Auth → state → navigate to dashboard — `AuthController` now proxies through `AuthSession` (a permanent `GetxService` registered in `InitialBinding`), so login/register/logout all stay in sync with the route guard and the Profile module.
- [x] **Dashboard Module:** Netflix-style course browsing → filter by category → navigate to detail — `DashController.setCategory()` now triggers a `GetCoursesByCategory` fetch; selecting "All" restores the carousel trio, any other chip swaps to the filtered list view. Empty + retry states added via `_ErrorBanner` and `_EmptyState` widgets.
- [x] **Course Detail Module:** Lesson list, progress tracking, enrollment — `CourseController` now loads `getLessonsForCourse`, hydrates the user's existing enrollment for this course, exposes `enroll()` + `toggleLessonComplete(Lesson)`, and computes a `progress` fraction. UI shows lesson list with per-lesson completion icon, an Enroll button (or "you're enrolled" message), a `LinearProgressIndicator` bar, and the count "X%". `MarkLessonCompleted` use-case wraps the repo call.
- [x] **Profile Module:** User info, enrolled courses list, settings — `ProfileController` replaces the placeholder. Bootstrap pulls cached session user (or re-fetches via `GetCurrentUser`), then `getEnrollmentsForUser` → `getCourseById` per enrollment to populate `enrolledCourses`. `CourseCarousel` widget reused from dashboard. `doLogout()` clears `AuthSession` and routes to `/login`. Screen handles loading + empty + error states.
- [x] Add navigation guards (redirect to login if not authenticated) — `AuthGuard` extends `GetMiddleware` and redirects unauthorized users to `/login`; `LoginGuard` redirects authenticated users away from `/login` to `/dashboard`. Guards wired on `/dashboard`, `/course-detail`, `/profile`, `/number-trivia`. Splash now probes `AuthSession.bootstrap()` and routes authenticated users straight to the dashboard (instead of always forcing `/login`).
- [x] Add loading states and error handling across all screens — every screen now has explicit loading (CircularProgressIndicator / LinearProgressIndicator), error Text + Retry button, and empty-states. Course detail error supports retry calling `loadCourse`. Profile error states for both the user fetch and the enrollments fetch.

### Key Learnings

- **AuthSession as a GetxService**: `Get.lazyPut<AuthController>` (per-route) was a poor fit for an app-wide login-state. Lifting it to a permanent `GetxService` means the route guard, Profile, Course Detail, and Splash can all `Get.find<AuthSession>()` the same instance and observe `currentUser` reactively.
- **GetMiddleware for route guards**: `@override RouteSettings? redirect(String? route)` returns null to allow or `RouteSettings(name: '/login')` to redirect. Two guards (`AuthGuard` + `LoginGuard`) cover both directions of the auth-flow.
- **SplashController probes session + waits branding**: uses `Future.wait([session.boot(), Future.delayed(1500ms)])` so the splash timer runs concurrently with the session probe rather than serially — no perceived wait increase.
- **Don't trust `Either.fold` with async callbacks**: `fold` is synchronous; if the `onRight` callback returns a Future, the outer `Future<void> result.fold(...)` won't await it. The calling code may think the operation completed when the inner async is still running. Fix by making BOTH callbacks return `Future<void>` and `await result.fold(...)`. This bug silently cleared the `enrolledCourses` list in `ProfileController._loadEnrollments` until tests caught it.
- **Dashboard category filter UX choice**: chips replace the three carousels with a `CourseCarousel` showing filtered results (turns out `CourseCarousel` is flexible enough for both the carousel-mode and a one-row filtered-mode; no new widget needed). The 'All' chip restores the original carousels; empty-filter-result has its own "No courses in {cat}" message.
- **CourseDetail hydration pattern**: `loadCourse` awaits course fetch + lessons fetch in parallel, then awaits `_hydrateEnrollmentForCourse(courseId)` (which calls `getEnrollmentsForUser` and finds the matching row). Lessons are a "soft failure" — if the lessons repo errors but course loads OK, the screen still shows what it can.
- **MarkLessonCompleted vs EnrollInCourse use-cases**: enrollment READS go through `EnrollmentRepository` directly in `CourseController` (no use-case wrapper, parity with Sprint 4a's pattern); enrollment WRITES (`enroll`, `markLessonCompleted`) go through use-case wrappers since they need validation + the convention "side effects go through the use-case layer."

### Files added

- `lib/modules/auth/auth_session.dart` — permanent `GetxService`.
- `lib/app/routes/auth_guard.dart` — `AuthGuard` + `LoginGuard`.
- `lib/domain/usecases/enrollments/mark_lesson_completed.dart` — wraps the repo method.
- `lib/domain/usecases/user/get_current_user.dart`, `get_user_by_id.dart` — wraps the user-repo reads.
- Tests: `test/modules/auth/auth_session_test.dart` (4), `auth_guard_test.dart` (4), `test/modules/profile/profile_controller_test.dart` (5), `test/modules/dashboard/dash_controller_category_test.dart` (5), `test/modules/courses/course_controller_test.dart` (7), `test/modules/profile/profile_screen_widget_test.dart` (1), `test/modules/courses/course_detail_widget_test.dart` (2). Total **28 new tests** (52 → 80 green).

### Files modified

- `lib/app/bindings/initial_binding.dart` — registers `AuthSession` permanently after the data-layer branching.
- `lib/app/routes/app_pages.dart` — `middlewares: [AuthGuard()]` on guarded routes; `[LoginGuard()]` on `/login`.
- `lib/modules/splash/splash_controller.dart` — `bootstrap()`-aware routing.
- `lib/modules/auth/auth_controller.dart` — `AuthSession` injection + `setUser`/`clear` calls on login/register/logout.
- `lib/modules/auth/auth_binding.dart` — passes `AuthSession` to `AuthController`.
- `lib/modules/dashboard/dash_controller.dart` — `filteredCourses`, `isFiltering`, `filterError`, `isFilteringActive`, `setCategory` triggers filtered fetch, `refreshDashboard` honors active category.
- `lib/modules/dashboard/dash_screen.dart` — splits body into `_AllView` (carousels) and `_FilteredView` (single carousel), empty + error + retry widgets, Search tab surfaces SnackBar "coming in a future sprint".
- `lib/modules/courses/course_binding.dart` — injects `GetLessonsForCourse`, `EnrollInCourse`, `MarkLessonCompleted`, `EnrollmentRepository`.
- `lib/modules/courses/course_controller.dart` — full rewrite + `loadCourse`, `enroll`, `toggleLessonComplete`, `progress` getter.
- `lib/modules/courses/course_detail_screen.dart` — full rewrite with lessons list + progress bar + enroll button.
- `lib/modules/profile/profile_binding.dart` — injects new use-cases + `CourseRepository`.
- `lib/modules/profile/profile_controller.dart` — full rewrite with `bootstrap`, `_loadEnrollments`, `doLogout`.
- `lib/modules/profile/profile_screen.dart` — full rewrite using `GetView<ProfileController>`, `CourseCarousel`, identity card, empty enrolled states, logout button.

### Completion Criteria

- [x] User can register, login, browse courses, enroll, track progress
- [x] All screens handle loading, error, and empty states
- [x] Auth guards prevent unauthorized access
- [x] Full user journey works end-to-end (verified via unit + widget tests; live run pending `supabase db push` from Sprint 4a)

### Verification

- `flutter analyze` → 0 issues
- `flutter test` → 80 of 80 passing (was 52 in Sprint 4a; +28 new)

---

## Sprint 6: Polish & Best Practices

**Goal:** Refine the app for production quality.

**Concepts:** Best practices, error handling, theming, performance

### Tasks

- [ ] Implement light/dark theme toggle
- [ ] Add pull-to-refresh on dashboard and course lists
- [ ] Add pagination to course list (infinite scroll)
- [ ] Review and clean up code for consistent patterns
- [ ] Final architecture review — verify layer separation is maintained
- [ ] Write unit tests for controllers and repositories
- [ ] Write widget tests for key screens
- [ ] Performance review — eliminate unnecessary rebuilds

### Completion Criteria

- [ ] Light/dark theme works
- [ ] Pagination and pull-to-refresh work
- [ ] Tests pass for all controllers and repositories
- [ ] Architecture review shows clean layer separation
- [ ] No unnecessary rebuilds in Obx widgets
