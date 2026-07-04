# AppexLMS — Testing Tracker

## Test Strategy

| Level | Type | Tool | Focus |
|-------|------|------|-------|
| Unit | Controller & Repository logic | `flutter_test` | Business rules, state transitions |
| Widget | UI component behavior | `flutter_test` | Rendering, user interactions |
| Integration | End-to-end flows | `integration_test` | Full user journeys |

---

## Test Summary

| Sprint | Unit Tests | Widget Tests | Integration Tests | Total | Pass | Fail | Skip | Coverage |
|--------|:----------:|:------------:|:-----------------:|:-----:|:----:|:----:|:----:|:--------:|
| 0      | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0% |
| 1      | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0% |
| 2      | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0% |
| 3 (cumulative total) | 26 | 1 | 0 | 27 | 27 | 0 | 0 | n/a |
| 4a (cumulative total) | 51 | 1 | 0 | 52 | 52 | 0 | 0 | n/a |
| 4b     | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0% |
| 5      | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0% |
| 6      | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0% |

---

## Sprint 0: Project Setup & Architecture Foundation

**Test Target:** Folder structure, GetX setup, navigation

| # | Test Name | Type | Status | Date | Notes |
|---|-----------|------|--------|------|-------|
| - | *No tests this sprint* | - | - | - | Setup only |

---

## Sprint 1: UI Foundations — Netflix-Inspired Dashboard

**Test Target:** Widget rendering, layout constraints, even-number dimensions

| # | Test Name | Type | Status | Date | Notes |
|---|-----------|------|--------|------|-------|
| 1.1 | Splash screen renders | Widget | Not Run | - | |
| 1.2 | Login screen renders | Widget | Not Run | - | |
| 1.3 | Dashboard hero section renders | Widget | Not Run | - | |
| 1.4 | Course carousel scrolls horizontally | Widget | Not Run | - | |
| 1.5 | No odd-number dimensions in UI | Widget | Not Run | - | Custom lint or test |
| 1.6 | Expanded/Flexible layouts — no overflow | Widget | Not Run | - | Multi-device test |

---

## Sprint 2: State Management with GetX

**Test Target:** Controller logic, reactive state updates, GetBuilder vs Obx behavior

| # | Test Name | Type | Status | Date | Notes |
|---|-----------|------|--------|------|-------|
| 2.1 | AuthController — login success | Unit | Not Run | - | |
| 2.2 | AuthController — login failure | Unit | Not Run | - | |
| 2.3 | AuthController — form validation (Obx) | Unit | Not Run | - | |
| 2.4 | AuthController — GetBuilder state update | Unit | Not Run | - | |
| 2.5 | DashboardController — load categories | Unit | Not Run | - | |
| 2.6 | CourseController — filter courses | Unit | Not Run | - | |
| 2.7 | GetBuilder rebuilds on update() | Widget | Not Run | - | |
| 2.8 | Obx rebuilds on .obs change | Widget | Not Run | - | |

---

## Sprint 3: Data Layer — Clean Architecture

**Test Target:** Entity/model mapping, repository pattern, mock provider

| # | Test Name | Type | Status | Date | Notes |
|---|-----------|------|--------|------|-------|
| 3.1 | User entity — model mapping (fromJson/toJson) | Unit | Not Run | - | |
| 3.2 | Course entity — model mapping | Unit | Not Run | - | |
| 3.3 | Lesson entity — model mapping | Unit | Not Run | - | |
| 3.4 | Enrollment entity — model mapping | Unit | Not Run | - | |
| 3.5 | MockUserRepository — CRUD operations | Unit | Not Run | - | |
| 3.6 | MockCourseRepository — read & filter | Unit | Not Run | - | |
| 3.7 | Repository DI — controller gets mock repo | Unit | Not Run | - | |
| 3.8 | Domain entities have no external deps | Unit | Not Run | - | Import analysis |

---

## Sprint 4a: Database — Supabase/PostgreSQL CRUD

**Test Target:** Supabase CRUD operations, RLS policies, real-time subscriptions

| # | Test Name | Type | Status | Date | Notes |
|---|-----------|------|--------|------|-------|
| 4a.1 | SupabaseUserRepo — create user | Unit | ✅ Pass | Sprint 4a | assertion covered by auth repo test: register Right on success. Tested in `test/data/repositories/supabase_auth_repository_impl_test.dart` |
| 4a.2 | SupabaseUserRepo — read user | Unit | ✅ Pass | Sprint 4a | `getUserById` → Right on success, Left(NotFoundFailure) on miss |
| 4a.3 | SupabaseUserRepo — update user | Unit | ⏭ N/A | Sprint 4a | Update user flows through Supabase Auth (signUp/signOut) — covered by 4a.1 and auth logout test. No direct `update()` exists on `UserRepository` yet |
| 4a.4 | SupabaseCourseRepo — read all courses | Unit | ✅ Pass | Sprint 4a | `test/data/repositories/supabase_course_repository_impl_test.dart` |
| 4a.5 | SupabaseCourseRepo — filter by category | Unit | ✅ Pass | Sprint 4a | same file |
| 4a.6 | SupabaseEnrollmentRepo — create enrollment | Unit | ✅ Pass | Sprint 4a | `test/data/repositories/supabase_enrollment_repository_impl_test.dart` |
| 4a.7 | SupabaseEnrollmentRepo — update progress | Unit | ✅ Pass | Sprint 4a | `markLessonCompleted` Right(Unit) on success, Left(ServerFailure) on error |
| 4a.8 | RLS — user cannot access other user data | Integration | Not Run | - | |
| 4a.9 | Real-time — course update reflects on dashboard | Integration | Not Run | - | |

---

## Sprint 4b: Database — MongoDB Comparison

**Test Target:** MongoDB CRUD, architecture swap verification

| # | Test Name | Type | Status | Date | Notes |
|---|-----------|------|--------|------|-------|
| 4b.1 | MongoUserRepo — create user | Unit | Not Run | - | |
| 4b.2 | MongoUserRepo — read user | Unit | Not Run | - | |
| 4b.3 | MongoUserRepo — update user | Unit | Not Run | - | |
| 4b.4 | MongoCourseRepo — read all courses | Unit | Not Run | - | |
| 4b.5 | MongoCourseRepo — filter by category | Unit | Not Run | - | |
| 4b.6 | MongoEnrollmentRepo — create enrollment | Unit | Not Run | - | |
| 4b.7 | MongoEnrollmentRepo — update progress | Unit | Not Run | - | |
| 4b.8 | Same unit tests for controllers pass with Mongo | Unit | Not Run | - | Architecture swap proof |
| 4b.9 | Domain layer unchanged after swap | Unit | Not Run | - | Import analysis |

---

## Sprint 5: Feature Modules — Full Integration

**Test Target:** End-to-end user flows, navigation guards, error handling

| # | Test Name | Type | Status | Date | Notes |
|---|-----------|------|--------|------|-------|
| 5.1 | Register → Login → Dashboard flow | Integration | Not Run | - | |
| 5.2 | Dashboard → Course detail → Enroll flow | Integration | Not Run | - | |
| 5.3 | Course detail → Track progress flow | Integration | Not Run | - | |
| 5.4 | Auth guard — unauthenticated redirect | Widget | Not Run | - | |
| 5.5 | Loading state displays on data fetch | Widget | Not Run | - | |
| 5.6 | Error state displays on fetch failure | Widget | Not Run | - | |
| 5.7 | Profile — view enrolled courses | Widget | Not Run | - | |

---

## Sprint 6: Polish & Best Practices

**Test Target:** Theme, pagination, performance, final regression

| # | Test Name | Type | Status | Date | Notes |
|---|-----------|------|--------|------|-------|
| 6.1 | Light/dark theme toggle | Widget | Not Run | - | |
| 6.2 | Pull-to-refresh reloads data | Widget | Not Run | - | |
| 6.3 | Pagination — infinite scroll loads more | Widget | Not Run | - | |
| 6.4 | No unnecessary Obx rebuilds | Unit | Not Run | - | Performance |
| 6.5 | Full regression — all previous tests pass | All | Not Run | - | |

---

## How to Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/auth_controller_test.dart

# Run with coverage
flutter test --coverage

# Run integration tests (requires device/emulator)
flutter test integration_test/
```

## Test File Structure

```
test/
├── unit/
│   ├── controllers/
│   │   ├── auth_controller_test.dart
│   │   ├── dashboard_controller_test.dart
│   │   └── course_controller_test.dart
│   ├── repositories/
│   │   ├── user_repository_test.dart
│   │   ├── course_repository_test.dart
│   │   └── enrollment_repository_test.dart
│   └── models/
│       ├── user_model_test.dart
│       ├── course_model_test.dart
│       └── enrollment_model_test.dart
├── widget/
│   ├── splash_screen_test.dart
│   ├── login_screen_test.dart
│   ├── dashboard_screen_test.dart
│   └── course_detail_screen_test.dart
└── integration/
    ├── auth_flow_test.dart
    ├── course_browse_flow_test.dart
    └── enrollment_flow_test.dart
```
