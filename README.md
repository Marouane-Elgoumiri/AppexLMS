# AppexLMS

A **Learning Management System** built with Flutter, designed as a guided project to master Flutter architecture and development.

<p align="center">
  <img src="assets/appexlms_light.png" alt="Flixify Logo" width="200"/>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" alt="Flutter"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart"></a>
  <a href="https://firebase.google.com"><img src="https://img.shields.io/badge/Firebase-Cloud%20Firestore-FFCA28?logo=firebase" alt="Firebase"></a>
</p>

## Key Concepts

| # | Concept | Focus |
|---|---------|-------|
| 1 | Imperative vs Declarative Programming | Understanding Flutter's declarative UI paradigm |
| 2 | Clean Flutter Architecture | Separation of concerns across data, domain, and presentation layers |
| 3 | UI Principles | Even-number dimensions, Expanded/Flexible, Rows & Columns, Netflix-style UI |
| 4 | State Management | GetX: GetBuilder, GetxController, .obs, Obx |
| 5 | Database Integration | CRUD with Supabase (PostgreSQL) and MongoDB |



## Architecture

```
lib/
├── app/                  # App-level config
│   ├── theme/            # Light/dark themes, spacing scale
│   ├── routes/           # GetX route definitions
│   └── bindings/         # GetX dependency bindings
├── data/                 # Data layer
│   ├── models/           # JSON/domain mapping
│   ├── providers/         # Supabase/MongoDB API calls
│   └── repositories/      # Repository implementations
├── domain/               # Domain layer (pure business logic)
│   ├── entities/         # Domain objects
│   └── repositories/      # Repository interfaces (abstract)
├── modules/              # Feature modules
│   ├── auth/             # Login/Register
│   ├── dashboard/        # Netflix-style course browser
│   ├── courses/          # Course detail & lessons
│   └── profile/          # User profile & settings
└── main.dart
```

## Tech Stack

- **Framework:** Flutter 3.x (Dart)
- **State Management:** GetX
- **Database (Primary):** Supabase (PostgreSQL)
- **Database (Secondary):** MongoDB Atlas
- **UI Style:** Netflix-inspired layout with consistent even-number dimension convention

## UI Convention

All dimensions (padding, margin, sizing, border-radius) use even numbers based on a 4px unit scale:

| Token | Value |
|-------|-------|
| `xs`  | 4px   |
| `sm`  | 8px   |
| `md`  | 16px  |
| `lg`  | 24px  |
| `xl`  | 32px  |
| `2xl` | 48px  |
| `3xl` | 64px  |

## Progress Tracking

- [Sprints](./Sprints.md) — Sprint-by-sprint development progress
- [Testing](./Testing.md) — Test results and coverage tracking

## Getting Started

```bash
# Clone the repository
git clone <repo-url>
cd appex

# Install dependencies
flutter pub get

# Run the app
flutter run
```


## 📸 Screenshots

| Auth Screen | Home | Profile |
|-------------|---------|--------|
| ![Auth](assets/preview.png) | ![Home](assets/preview_profile.png) | ![Profile](assets/preview_home.png) 


## Project Milestones

| Phase | Focus | Status |
|-------|-------|--------|
| 0 | Project Setup & Architecture Foundation | Not Started |
| 1 | UI Foundations — Netflix-Inspired Dashboard | Not Started |
| 2 | State Management with GetX | Not Started |
| 3 | Data Layer — Clean Architecture | Not Started |
| 4a | Database — Supabase/PostgreSQL CRUD | Not Started |
| 4b | Database — MongoDB Comparison | Not Started |
| 5 | Feature Modules — Full Integration | Not Started |
| 6 | Polish & Best Practices | Not Started |
