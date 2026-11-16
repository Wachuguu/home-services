# Tasker Engineering Roadmap & TODO

This document tracks all missing, incomplete, and half-built functionality across the Tasker codebase. Items are organized by functional area and ranked in strict priority order with explicit severity labels:
- **`[Blocker]`**: Must be implemented or fixed before any end-to-end user flow or production deployment can function.
- **`[Should-Fix]`**: High-impact defect, data inconsistency, or missing capability required for a reliable production experience.
- **`[Nice-to-Have]`**: Quality-of-life enhancements, architectural refinements, and future roadmap items.

---

## 1. Jobs and Payments

### 1.1 `[Blocker]` Expose and Execute Escrow Payout (B2C Release)
- **Current State:** `PaymentService.releasePayment(UUID jobId)` exists in `tasker-backend/src/main/java/com/tasker/service/PaymentService.java#L102-L119`, but it is **never called**. It is neither triggered automatically when a provider completes a job (`JobService.completeJob`), nor exposed via any endpoint in `PaymentController.java`.
- **Action Required:**
  1. Determine the release trigger: either invoke `paymentService.releasePayment(job.getId())` inside `JobService.completeJob()`, or expose `POST /api/payments/{jobId}/release` restricted to clients/admins.
  2. Transition payment status to `RELEASED` only upon confirmed B2C callback execution.

### 1.2 `[Blocker]` Fix Broken Provider Matching Flow in Frontend
- **Current State:** In `tasker-frontend/lib/features/jobs/presentation/screens/create_job_screen.dart#L88`, creating a job routes to `/providers/nearby/$categoryId`. In `tasker-frontend/lib/features/jobs/presentation/screens/provider_match_screen.dart#L198`, tapping "Select Provider" navigates to `/jobs/create/$categoryId?providerId=${provider.id}`, creating an infinite loop. Furthermore, `JobRemoteDs.matchProvider` (`tasker-frontend/lib/features/jobs/data/datasources/job_remote_ds.dart#L32`) is never called.
- **Action Required:**
  1. Pass the created `jobId` from `CreateJobScreen` to `ProviderMatchScreen` (e.g. `/providers/nearby/:categoryId?jobId=:jobId`).
  2. In `ProviderMatchScreen`, invoke `JobRemoteDs.matchProvider(jobId, provider.id)` when the user taps "Select Provider".
  3. Navigate to `JobDetailScreen` upon successful match.

### 1.3 `[Blocker]` Resolve Job Status Conflict Between Payment and Job Start
- **Current State:** When an M-Pesa STK callback succeeds, `PaymentService.handleSTKCallback()` (`tasker-backend/src/main/java/com/tasker/service/PaymentService.java#L81`) updates the job status directly to `IN_PROGRESS`. However, `JobController.startJob()` (`tasker-backend/src/main/java/com/tasker/service/JobService.java#L104`) requires the job to be in `MATCHED` status (`if (job.getStatus() != JobStatus.MATCHED) throw new InvalidJobStateException(...)`). If payment advances the job to `IN_PROGRESS`, the provider cannot subsequently call `startJob`.
- **Action Required:** Align state machine transitions. Either:
  - Keep job in `MATCHED` status after escrow deposit and require provider to call `startJob` to enter `IN_PROGRESS`, OR
  - Introduce an explicit payment state (e.g., `ESCROW_FUNDED`) that precedes `IN_PROGRESS`.

### 1.4 `[Blocker]` Parse Real M-Pesa STK Callback Metadata
- **Current State:** `PaymentService.handleSTKCallback()` (`tasker-backend/src/main/java/com/tasker/service/PaymentService.java#L78`) hardcodes `payment.setMpesaReceiptNumber("DUMMY_RECEIPT"); // Placeholder`.
- **Action Required:** Extract the real receipt number (`MpesaReceiptNumber`), transaction amount, and transaction date from the nested `CallbackMetadata.Item` array in Daraja's JSON callback payload.

### 1.5 `[Blocker]` Implement Real Safaricom Daraja B2C Credentials & Encryption
- **Current State:** `MpesaService.initiateB2CPayment()` (`tasker-backend/src/main/java/com/tasker/service/MpesaService.java#L90-L91`) hardcodes dummy values: `payload.put("SecurityCredential", "dummy-security-credential")` and `payload.put("InitiatorName", "APIUser")`.
- **Action Required:**
  1. Implement RSA encryption of the initiator password using Safaricom's public X.509 certificate.
  2. Make `mpesa.initiator-name`, `mpesa.security-credential`, and certificates configurable via environment variables.

### 1.6 `[Blocker]` Implement B2C Callback and Timeout Processing
- **Current State:** `PaymentService.handleB2CCallback()` (`tasker-backend/src/main/java/com/tasker/service/PaymentService.java#L122-L124`) has an empty body (`// Handle B2C result`), and `MpesaCallbackController.handleB2CTimeout()` (`tasker-backend/src/main/java/com/tasker/controller/MpesaCallbackController.java#L31-L34`) is an empty stub.
- **Action Required:** Handle Daraja B2C result callbacks, verify transaction outcome, persist B2C transaction IDs, and update payment status to `RELEASED` or `FAILED`. Handle timeout queue retries.

### 1.7 `[Should-Fix]` Eliminate Fallback Mock Tokens in Production
- **Current State:** `MpesaService.getOAuthToken()` (`tasker-backend/src/main/java/com/tasker/service/MpesaService.java#L45`) returns `"dummy-token"` on error, and `initiateSTKPush()` (`tasker-backend/src/main/java/com/tasker/service/MpesaService.java#L80-L83`) catches all network/HTTP failures and returns a synthetic successful response (`CheckoutRequestID: dummy-checkout-...`).
- **Action Required:** Remove catch-all dummy responses in production. Throw descriptive `PaymentException` instances when Daraja API calls fail so clients receive proper error responses.

### 1.8 `[Should-Fix]` Implement Escrow Refund Workflow
- **Current State:** `PaymentStatus.REFUNDED` exists in the database schema check constraint and Java enum (`tasker-backend/src/main/java/com/tasker/model/PaymentStatus.java`), but no refund service, B2C reversal logic, or cancellation refund trigger exists.
- **Action Required:** If a client or provider cancels a job that has funds held in escrow (`PaymentStatus.HELD`), trigger an automatic refund or administrative reversal process.

### 1.9 `[Should-Fix]` Add Real-Time Payment Verification to Frontend
- **Current State:** In `tasker-frontend/lib/features/payment/presentation/widgets/mpesa_prompt_dialog.dart#L44-L47`, clicking "Done" simply dismisses the dialog. The app never queries `/api/payments/{jobId}` to check whether payment completed.
- **Action Required:** Implement polling or listen for FCM push notifications to display payment success/failure feedback in the UI before dismissing the dialog.

### 1.10 `[Nice-to-Have]` Dynamic Job Cost & Cost Adjustment
- **Current State:** `CreateJobScreen` hardcodes `estimatedCost: 1500` (`tasker-frontend/lib/features/jobs/presentation/screens/create_job_screen.dart#L85`). `Job.finalCost` exists in the database but is never set.
- **Action Required:** Populate estimated cost dynamically from category base prices or provider hourly rates, and allow final cost adjustments prior to payment.

---

## 2. Reviews

### 2.1 `[Blocker]` Create Backend `ReviewController`
- **Current State:** `ReviewService.java` (`tasker-backend/src/main/java/com/tasker/service/ReviewService.java`) implements `createReview()` (validating job completion, preventing duplicates, and updating provider running average rating) and `getReviewsByProvider()`. However, **no controller exists** to expose these methods.
- **Action Required:**
  1. Create `tasker-backend/src/main/java/com/tasker/controller/ReviewController.java`.
  2. Implement `POST /api/reviews` accepting `CreateReviewRequest(UUID jobId, Integer rating, String comment)` using `@AuthenticationPrincipal UserPrincipal principal`.
  3. Implement `GET /api/reviews/provider/{providerId}` returning `List<ReviewResponse>`.
  4. Create DTO records `CreateReviewRequest` and `ReviewResponse`.

### 2.2 `[Blocker]` Build Review Submission UI in Frontend
- **Current State:** There is zero review UI in the frontend. When a job reaches `COMPLETED` status, the user has no way to leave a rating or review.
- **Action Required:**
  1. Create `ReviewRemoteDs` and `ReviewController` in `tasker-frontend/lib/features/reviews/`.
  2. Add a review submission prompt on `JobDetailScreen` when `job.status == 'COMPLETED'`.
  3. Include star rating selection (1 to 5) and optional comment text field.

### 2.3 `[Should-Fix]` Integrate Reviews Display on Provider Profile
- **Current State:** `rating_stars.dart` exists in `tasker-frontend/lib/features/profile/presentation/widgets/rating_stars.dart` but is orphaned and unused. `ProfileScreen` does not display reviews or breakdown of ratings.
- **Action Required:** Display recent reviews, ratings breakdown, and verified badges on provider profile screens and match cards.

### 2.4 `[Nice-to-Have]` Reciprocal Client Reviews
- **Current State:** The schema supports bidirectional reviews via `reviewer_id` and `reviewee_id` (`V1__init_schema.sql#L81-L82`), but `ReviewService.java#L48` hardcodes `User reviewee = job.getProvider()`, permitting only clients to review providers.
- **Action Required:** Allow providers to review clients upon job completion.

---

## 3. Tests

### 3.1 `[Blocker]` Build Backend Unit & Integration Test Suite
- **Current State:** **0 backend tests exist.** The `tasker-backend/src/test` directory is missing entirely. Maven test-compile reports `No sources to compile`. Dependencies (`spring-boot-starter-test`, `spring-security-test`, `testcontainers`, `postgis-jdbc`) are present in `pom.xml#L93-L123` but unused.
- **Action Required:**
  1. Create `tasker-backend/src/test/java/com/tasker/`.
  2. **Auth & Security Tests:** Unit/integration tests for registration (role enforcement, password hashing, duplicates), login, and JWT filter authorization.
  3. **Job Lifecycle Tests:** Test state machine transitions (`REQUESTED` -> `MATCHED` -> `IN_PROGRESS` -> `COMPLETED` / `CANCELLED`), ensuring unauthorized users cannot mutate jobs.
  4. **PostGIS Spatial Matching Tests:** Spin up Testcontainers with PostgreSQL + PostGIS to test `findNearbyAvailableProvidersByCategory` query logic, bounding limits, and distance sorting.
  5. **M-Pesa Callback Tests:** Test STK push callback parsing and escrow state changes.
  6. **Review Service Tests:** Verify rating calculations and constraint enforcement.

### 3.2 `[Blocker]` Build Frontend Unit & Widget Test Suite
- **Current State:** **0 frontend tests exist.** There is no `test/` directory in `tasker-frontend/`.
- **Action Required:**
  1. Create `tasker-frontend/test/`.
  2. **Model Deserialization Tests:** Test JSON parsing for `User`, `Job`, `ServiceCategory`, and `Payment`. Catch type errors (e.g. `categoryId` `int` vs `String`) before runtime.
  3. **Controller Tests:** Test Riverpod `AuthController`, `JobController`, `CategoryController`, and `PaymentController` with mocked Dio responses.
  4. **Widget Tests:** Test login validation, registration flow, job detail action buttons, and empty states.

### 3.3 `[Should-Fix]` CI Automated Test Execution
- **Current State:** No GitHub Actions workflow exists for running automated tests on pull requests or commits.
- **Action Required:** Create `.github/workflows/ci.yml` running `mvn clean test` for backend and `flutter test` + `flutter analyze` for frontend.

---

## 4. Frontend

### 4.1 `[Blocker]` Fix Model Deserialization & Type Mismatches
- **Current State:**
  1. In `tasker-frontend/lib/features/jobs/data/datasources/job_remote_ds.dart#L65-L71`, `getNearbyProviders()` maps backend `ProviderMatchResponse` to `User.fromJson(e)`. The backend returns `providerId`, whereas `User.fromJson` expects `id`. This leaves `user.id` empty (`""`) and drops distance, hourly rate, and verification flags.
  2. In `tasker-frontend/lib/features/jobs/domain/models/job.dart#L44`, `categoryId: json['categoryId'] ?? ''` crashes with `TypeError` when the backend returns an integer `categoryId`.
- **Action Required:**
  1. Create a dedicated `ProviderMatch` domain model in Flutter matching `ProviderMatchResponse`.
  2. Update `Job.fromJson` to use `categoryId: json['categoryId']?.toString() ?? ''`.

### 4.2 `[Blocker]` Configurable Environment Base URL
- **Current State:** `ApiEndpoints.baseUrl` (`tasker-frontend/lib/core/constants/api_endpoints.dart#L4`) hardcodes `http://10.0.2.2:8080/api/` (Android) and `http://localhost:8080/api/` (iOS/desktop). It cannot point to a deployed Render backend.
- **Action Required:** Use `String.fromEnvironment('API_BASE_URL', defaultValue: ...)` or `flutter_dotenv` to allow dynamic environment configuration during build (`flutter build --dart-define=API_BASE_URL=https://...`).

### 4.3 `[Blocker]` Wire Provider Online/Offline Availability Toggle
- **Current State:** In `tasker-frontend/lib/features/home/presentation/screens/provider_home_screen.dart#L72-L75`, the availability `Switch` only calls `setState(() => _isOnline = val)`. It never calls `PUT /api/providers/me/availability`.
- **Action Required:**
  1. Add `updateAvailability` method in a provider remote datasource calling `PUT /api/providers/me/availability`.
  2. Persist and reflect online status against the backend.

### 4.4 `[Should-Fix]` Wire Location and FCM Token Synchronization
- **Current State:** `ApiEndpoints.updateLocation` and `ApiEndpoints.updateFcmToken` are declared in `tasker-frontend/lib/core/constants/api_endpoints.dart#L10-L11`, but **never called** anywhere in the frontend.
- **Action Required:**
  1. Upon login and permission grant, call `PUT /api/users/me/location` with GPS coordinates so providers are visible in spatial searches.
  2. Initialize Firebase Messaging, retrieve device FCM token, and call `PUT /api/users/me/fcm-token`.

### 4.5 `[Should-Fix]` Replace Hardcoded Provider Stats with Real Data
- **Current State:** In `tasker-frontend/lib/features/home/presentation/screens/provider_home_screen.dart#L83-L84`, `StatsCard` values are hardcoded strings (`"24"` completed, `"4.9"` rating).
- **Action Required:** Fetch real completed job counts and average ratings from the backend user profile/dashboard API.

### 4.6 `[Should-Fix]` Clean Up Orphaned Widgets and Deprecated Flutter APIs
- **Current State:**
  1. `SkillChip` (`skill_chip.dart`) and `ProviderMatchCard` (`provider_match_card.dart`) are unused.
  2. `flutter analyze` reports 24 issues across the frontend (deprecated `withOpacity`, `activeColor`, `background`, and direct `print` statements).
- **Action Required:** Integrate or remove unused widgets, upgrade deprecated theme and color methods to `.withValues()`, and replace `print` calls with a structured logger.

### 4.7 `[Nice-to-Have]` Implement Google Maps Widget
- **Current State:** `google_maps_flutter` is listed in `pubspec.yaml`, and `AndroidManifest.xml` has a placeholder for `MAPS_API_KEY`, but no `GoogleMap` widget exists in Dart code. Location is only shown as text.
- **Action Required:** Embed interactive maps in `ProviderMatchScreen` and `JobDetailScreen` showing provider and client locations.

### 4.8 `[Nice-to-Have]` Implement Provider Skill Self-Management
- **Current State:** Providers cannot add or edit their own skills; skills only exist via dev seed migrations.
- **Action Required:** Create screens allowing providers to select categories, enter hourly rates, and submit certifications for verification.

---

## 5. Deployment

### 5.1 `[Blocker]` Set `SPRING_PROFILES_ACTIVE=prod` in Render Blueprint
- **Current State:** `render.yaml` (root) and `tasker-backend/render.yaml` define environment variables for database credentials, but **omit `SPRING_PROFILES_ACTIVE`**. Without this, Spring Boot launches with the `default` profile instead of `prod`, causing non-production defaults to execute.
- **Action Required:** Add `- key: SPRING_PROFILES_ACTIVE\n  value: prod` to the `envVars` section in `render.yaml`.

### 5.2 `[Blocker]` Verify PostGIS Availability on Render PostgreSQL
- **Current State:** The database initialization migration `V1__init_schema.sql#L1` runs `CREATE EXTENSION IF NOT EXISTS postgis;`. If Render's managed PostgreSQL instance requires superuser privileges or a specific extension flag, migrations will fail on first boot.
- **Action Required:** Confirm PostGIS extension support on the selected Render database plan, or provision a PostGIS-enabled database instance.

### 5.3 `[Blocker]` Configure Public Webhook URL for M-Pesa Callbacks
- **Current State:** `render.yaml` sets `MPESA_CALLBACK_BASE_URL` with `sync: false`. Daraja callbacks cannot reach localhost or internal IPs.
- **Action Required:** Set `MPESA_CALLBACK_BASE_URL` to `https://tasker-api.onrender.com` (or custom domain) and configure Safaricom Daraja Developer Portal callback endpoints.

### 5.4 `[Should-Fix]` Consolidate Duplicate `render.yaml` Files
- **Current State:** Identical `render.yaml` files exist at both repository root (`./render.yaml`) and inside `tasker-backend/render.yaml`, inviting configuration drift.
- **Action Required:** Maintain a single authoritative `render.yaml` at the repository root and remove the nested duplicate.

### 5.5 `[Should-Fix]` Configure Flutter Release Signing
- **Current State:** In `tasker-frontend/android/app/build.gradle.kts#L37`, release builds use debug signing keys (`signingConfig = signingConfigs.getByName("debug")`).
- **Action Required:** Configure Android keystore signing and iOS distribution certificates for release builds.

### 5.6 `[Nice-to-Have]` Continuous Deployment Pipeline for Flutter
- **Current State:** There is no automated build or distribution pipeline for Flutter (e.g. web deployment to Firebase Hosting/Render, or APK/AAB artifact generation).
- **Action Required:** Create a GitHub Actions workflow to build release artifacts on release tags.
