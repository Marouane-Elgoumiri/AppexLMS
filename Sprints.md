# AppexLMS — Sprint Tracker

## Sprint Overview

| Sprint | Phase | Duration | Status |
|--------|-------|----------|--------|
| 0 | Project Setup & Architecture Foundation | Week 1 | Not Started |
| 1 | UI Foundations — Netflix-Inspired Dashboard | Week 2-3 | Not Started |
| 2 | State Management with GetX | Week 4 | Not Started |
| 3 | Data Layer — Clean Architecture | Week 5 | Not Started |
| 4a | Database — Supabase/PostgreSQL CRUD | Week 6-7 | Not Started |
| 4b | Database — MongoDB Comparison | Week 8 | Not Started |
| 5 | Feature Modules — Full Integration | Week 9-10 | Not Started |
| 6 | Polish & Best Practices | Week 11 | Not Started |

---

## Sprint 0: Project Setup & Architecture Foundation

**Goal:** Scaffold the project, configure dependencies, establish architecture patterns.

**Concepts:** Imperative vs Declarative, Clean Flutter Architecture

### Tasks

- [ ] Create Flutter project and set up folder structure (app/, data/, domain/, modules/)
- [ ] Install GetX and configure initial setup
- [ ] Set up Supabase project (free tier) and configure client
- [ ] Define AppTheme with even-number spacing scale
- [ ] Set up GetX routing and initial bindings
- [ ] Create placeholder screens for all modules

### Key Learnings

- Imperative vs Declarative: Flutter rebuilds the entire widget subtree on state change (declarative), vs manually mutating DOM elements (imperative)
- Clean Architecture layers: Presentation → Domain ← Data (domain has no dependencies)

### Completion Criteria

- [ ] `flutter run` launches app with placeholder screens
- [ ] Folder structure matches architecture spec
- [ ] GetX navigation works between placeholder screens

---

## Sprint 1: UI Foundations — Netflix-Inspired Dashboard

**Goal:** Build static Netflix-style UI with proper layout discipline.

**Concepts:** Rows & Columns, Expanded/Flexible, Even-number dimensions, Responsive layout

### Tasks

- [ ] Design and build Splash Screen
- [ ] Design and build Login Screen (static, no auth logic yet)
- [ ] Build Dashboard hero banner section
- [ ] Build horizontal course carousel rows
- [ ] Build category filter chips
- [ ] Build bottom navigation bar
- [ ] Enforce even-number dimension convention across all screens
- [ ] Use Expanded/Flexible for responsive layouts

### Key Learnings

- `Expanded` fills remaining space (forces size), `Flexible` wraps content but can grow
- Even-number convention: base unit 4px, all padding/margin/sizing use multiples of 4
- Netflix layout pattern: Column → Hero + multiple horizontal ListView.builder rows

### Completion Criteria

- [ ] All screens render correctly on multiple device sizes
- [ ] No hardcoded odd-number dimensions in UI code
- [ ] Expanded/Flexible used correctly (no overflow errors)

---

## Sprint 2: State Management with GetX

**Goal:** Add reactive state management to existing UI screens.

**Concepts:** GetxController, GetBuilder, .obs, Obx

### Tasks

- [ ] Create `AuthController` (GetxController) with GetBuilder pattern
- [ ] Refactor `AuthController` to also use .obs + Obx pattern (side by side comparison)
- [ ] Create `DashboardController` — manage course categories, featured courses
- [ ] Create `CourseController` — manage course list, filters
- [ ] Set up GetX Bindings for dependency injection
- [ ] Wire controllers to existing UI screens

### Key Learnings

- `GetBuilder` + `update()`: Manual, imperative-style updates. Call `update()` when you want to rebuild. Good for infrequent updates, less overhead.
- `.obs` + `Obx`: Reactive, declarative-style. Auto-rebuilds when value changes. Good for form validation, counters, toggles.
- Rule of thumb: Use GetBuilder for page-level state, Obx for fine-grained reactive widgets

### Completion Criteria

- [ ] Login form shows reactive validation with Obx
- [ ] Dashboard loads course data through controller
- [ ] GetX bindings inject controllers correctly
- [ ] Student can explain GetBuilder vs Obx difference

---

## Sprint 3: Data Layer — Clean Architecture

**Goal:** Separate data logic from controllers using the repository pattern.

**Concepts:** Repository pattern, Domain entities, Data models, Dependency inversion

### Tasks

- [ ] Define domain entities: `User`, `Course`, `Lesson`, `Enrollment`
- [ ] Create data models with `fromJson`/`toJson` methods
- [ ] Define abstract repository interfaces in `domain/repositories/`
- [ ] Implement concrete repositories in `data/repositories/`
- [ ] Wire repositories to controllers via GetX bindings
- [ ] Add mock data provider for development without DB

### Key Learnings

- Entity (domain) vs Model (data): Entity is pure Dart, Model knows about JSON serialization
- Repository interface in domain → implementation in data = Dependency Inversion principle
- Controllers depend on abstract interfaces, not concrete implementations

### Completion Criteria

- [ ] Domain entities have no external dependencies
- [ ] Repository interfaces are abstract classes
- [ ] Controllers receive repositories via DI (not direct instantiation)
- [ ] App works with mock data provider

---

## Sprint 4a: Database — Supabase/PostgreSQL CRUD

**Goal:** Connect to Supabase and implement full CRUD operations.

**Concepts:** SQL schema design, Supabase SDK, CRUD patterns, Row Level Security

### Tasks

- [ ] Design database schema (users, courses, lessons, enrollments, progress)
- [ ] Create Supabase tables and relationships
- [ ] Configure Row Level Security (RLS) policies
- [ ] Implement Supabase provider: Users CRUD
- [ ] Implement Supabase provider: Courses CRUD (read, filter)
- [ ] Implement Supabase provider: Enrollments CRUD
- [ ] Implement Supabase provider: Progress tracking (create, update)
- [ ] Add Supabase real-time subscriptions for course updates
- [ ] Wire Supabase providers into existing repositories

### Key Learnings

- Supabase SDK: `supabase.from('table').select()/.insert()/.update()/.delete()`
- RLS policies: secure data per-user at the database level
- CRUD mapping: Create = insert, Read = select, Update = update, Delete = delete

### Completion Criteria

- [ ] Full CRUD works for all entities via Supabase
- [ ] RLS policies prevent unauthorized data access
- [ ] Real-time updates reflect on dashboard
- [ ] Mock provider can be swapped for Supabase provider via DI

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

- [ ] **Auth Module:** Login/Register → Supabase Auth → state → navigate to dashboard
- [ ] **Dashboard Module:** Netflix-style course browsing → filter by category → navigate to detail
- [ ] **Course Detail Module:** Lesson list, progress tracking, enrollment
- [ ] **Profile Module:** User info, enrolled courses list, settings
- [ ] Add navigation guards (redirect to login if not authenticated)
- [ ] Add loading states and error handling across all screens

### Completion Criteria

- [ ] User can register, login, browse courses, enroll, track progress
- [ ] All screens handle loading, error, and empty states
- [ ] Auth guards prevent unauthorized access
- [ ] Full user journey works end-to-end

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
