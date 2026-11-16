# Tasker Architecture Documentation

> **Status:** Unfinished / In Active Development  
> **Repository:** Tasker (Home Services Marketplace)  
> **Backend:** Spring Boot 3.4.2 (Java 21), PostgreSQL 16 with PostGIS, Hibernate Spatial, Flyway  
> **Frontend:** Flutter (Dart `>=3.4.0 <4.0.0`), Riverpod, GoRouter, Dio  
> **Deploy Target:** Render (Web Service Docker runtime + Managed PostgreSQL)

---

## 1. What Exists Today

Tasker is designed as a two-sided on-demand marketplace connecting clients needing home services (plumbing, cleaning, electrical repairs, carpentry, etc.) with local service providers.

### Backend (`tasker-backend`)
- **Framework & Runtime:** Java 21 with Spring Boot 3.4.2, managed by Maven (`tasker-backend/pom.xml`). Note that Maven coordinates remain `com.homeServices:homeServices-backend:0.0.1-SNAPSHOT` while source packages use `com.tasker.*`.
- **Database & Spatial:** PostgreSQL with PostGIS extension. Spatial location mapping uses JTS (`org.locationtech.jts:jts-core:1.20.0`) and Hibernate Spatial with `GEOGRAPHY(Point, 4326)` columns (`tasker-backend/src/main/resources/db/migration/V1__init_schema.sql`).
- **Migrations:** Managed via Flyway. Production migrations live in `tasker-backend/src/main/resources/db/migration/` (`V1__init_schema.sql`, `V2__seed_categories.sql`, `V4__reseed_missing_categories.sql`). Dev-only seed migrations live in `tasker-backend/src/main/resources/db/dev/` (`V3__seed_test_users.sql`).
- **Security & RBAC:** Spring Security with stateless sessions, BCrypt password hashing, and HMAC-SHA256 JWT tokens via JJWT 0.12.6 (`tasker-backend/src/main/java/com/tasker/security/`). Roles defined: `CLIENT`, `PROVIDER`, `ADMIN`.
- **Admin Bootstrapping:** `AuthService.bootstrapAdmin()` executes on `ApplicationReadyEvent` and seeds an admin user if environment variables `ADMIN_EMAIL` and `ADMIN_PASSWORD` are provided (`tasker-backend/src/main/java/com/tasker/service/AuthService.java#L43-L76`).
- **Spatial Geo-Matching:** Native PostGIS query utilizing `ST_DWithin` and `ST_Distance` on geography points (`tasker-backend/src/main/java/com/tasker/repository/UserRepository.java#L21-L46`).
- **Payments:** Safaricom Daraja M-Pesa integration structure with STK Push (customer pay-in) and B2C payout methods (`tasker-backend/src/main/java/com/tasker/service/MpesaService.java`), but callback processing and credentials contain hardcoded mock fallbacks.
- **Push Notifications:** Firebase Cloud Messaging client integration via `FirebaseAdmin` SDK (`tasker-backend/src/main/java/com/tasker/service/NotificationService.java` and `tasker-backend/src/main/java/com/tasker/config/FirebaseConfig.java`). Requires service account JSON path in `app.firebase.config.path`.
- **Packaging & Deployment:** Multi-stage Dockerfile (`tasker-backend/Dockerfile`) running as non-root user `appuser`. Render infrastructure blueprints in `render.yaml` and `tasker-backend/render.yaml`.
- **Tests:** **None.** There is no `src/test` directory in `tasker-backend`.

### Frontend (`tasker-frontend`)
- **Framework & SDK:** Flutter targeting Android, iOS, and Linux (`tasker-frontend/pubspec.yaml`).
- **State Management:** Riverpod 2.6.1 (`flutter_riverpod`) utilizing `AsyncNotifier` and `FutureProvider`.
- **Navigation:** GoRouter 14.8.1 with declarative auth redirection (`tasker-frontend/lib/app/router.dart`).
- **Networking:** Dio 5.7.0 with custom `AuthInterceptor` injecting JWT Bearer tokens from `FlutterSecureStorage` (`tasker-frontend/lib/core/network/`).
- **GPS Location:** Device GPS lookup using `geolocator: ^13.0.2` (`tasker-frontend/lib/features/jobs/presentation/screens/provider_match_screen.dart`).
- **Screens:** Splash, Login, Register, Client Home, Provider Home, Category Grid, Create Job, Job List, Job Detail, Provider Match, Payment, Profile.
- **Tests:** **None.** There is no Flutter `test/` directory.

---

## 2. Modules and Entry Points

### Backend Structure
- **Root Directory:** `tasker-backend/`
- **Build Configuration:** `tasker-backend/pom.xml`
- **Application Entry Point:** `com.tasker.TaskerApplication` at `tasker-backend/src/main/java/com/tasker/TaskerApplication.java`.
- **Configuration Profiles:**
  - `default`: `tasker-backend/src/main/resources/application.yml` (Port 8080, DDL validation, default JWT expiration 24h, default search radius 10 km).
  - `dev`: `tasker-backend/src/main/resources/application-dev.yml` (Enables SQL formatting and Flyway dev seed location `classpath:db/dev`).
  - `prod`: `tasker-backend/src/main/resources/application-prod.yml` (Enforces production DB environment variables and requires non-null `JWT_SECRET`).
- **Package Hierarchy:**
  - `com.tasker.config`: CORS, Firebase, Jackson, M-Pesa properties, RestTemplate.
  - `com.tasker.controller`: REST controllers for Auth, Users, Providers, Jobs, Payments, M-Pesa callbacks, Categories, Admin.
  - `com.tasker.dto`: Request records and response records.
  - `com.tasker.exception`: Custom runtime exceptions and `GlobalExceptionHandler`.
  - `com.tasker.model`: JPA entities and domain enums.
  - `com.tasker.repository`: Spring Data JPA repositories and native SQL projections.
  - `com.tasker.security`: Security filter chain, JWT provider, auth filter, user principal.
  - `com.tasker.service`: Business logic for Auth, Users, Jobs, Payments, Location/Matching, M-Pesa, Notifications, Reviews, Admin.

### Frontend Structure
- **Root Directory:** `tasker-frontend/`
- **Configuration:** `tasker-frontend/pubspec.yaml`, `tasker-frontend/analysis_options.yaml`
- **Application Entry Point:** `main()` in `tasker-frontend/lib/main.dart`, which initializes Flutter bindings, attempts Firebase initialization, and mounts `HomeServicesApp` (`tasker-frontend/lib/app/app.dart`).
- **Router:** `routerProvider` in `tasker-frontend/lib/app/router.dart` defining 12 GoRoutes.
- **Directory Layout:**
  - `lib/app`: Application widget, GoRouter setup, dark theme definitions (`app_theme.dart`, `app_colors.dart`).
  - `lib/core`: Constants (`api_endpoints.dart`, `app_constants.dart`), network (`dio_client.dart`, `auth_interceptor.dart`), storage (`secure_storage_service.dart`), utils (`validators.dart`).
  - `lib/features`: Feature modules divided into `data/datasources`, `domain/models`, and `presentation/` (`controllers`, `screens`, `widgets`):
    - `auth`: Login, registration, splash, user model.
    - `categories`: Category grid, cards, category model.
    - `home`: Client dashboard and Provider dashboard with status toggle.
    - `jobs`: Job creation, list, detail, provider matching, job model.
    - `payment`: M-Pesa payment initiation screen, dialog, payment model.
    - `profile`: User profile view, logout.
  - `lib/shared/widgets`: Reusable UI components (`app_scaffold.dart`, `dynamic_background.dart`, `empty_state_widget.dart`, `error_snackbar.dart`, `gradient_app_bar.dart`, `loading_overlay.dart`, `shimmer_loading_widget.dart`).
  - Platform targets: Android (`tasker-frontend/android/`), iOS (`tasker-frontend/ios/`), Linux (`tasker-frontend/linux/`).

---

## 3. Data Model

The schema is defined via Flyway in `tasker-backend/src/main/resources/db/migration/V1__init_schema.sql` and mapped by JPA entities in `tasker-backend/src/main/java/com/tasker/model/`.

### 1. `users` Table / `User` Entity
*File paths:* `tasker-backend/src/main/resources/db/migration/V1__init_schema.sql#L4-L21`, `tasker-backend/src/main/java/com/tasker/model/User.java`
- `id` (UUID, PK, `uuid_generate_v4()`)
- `email` (VARCHAR(255), UNIQUE, NOT NULL)
- `password_hash` (VARCHAR(255), NOT NULL)
- `full_name` (VARCHAR(255), NOT NULL)
- `phone_number` (VARCHAR(20), UNIQUE, NOT NULL)
- `role` (VARCHAR(20), NOT NULL, CHECK: `'CLIENT'`, `'PROVIDER'`, `'ADMIN'`)
- `profile_image_url` (TEXT)
- `location` (GEOGRAPHY(Point, 4326), with GIST spatial index)
- `address` (TEXT)
- `is_available` (BOOLEAN, DEFAULT true, with filtered B-tree index where `true`)
- `rating` (DECIMAL(3,2), DEFAULT 0.00)
- `total_reviews` (INTEGER, DEFAULT 0)
- `fcm_token` (VARCHAR(255))
- `created_at`, `updated_at` (TIMESTAMPTZ)

### 2. `service_categories` Table / `ServiceCategory` Entity
*File paths:* `tasker-backend/src/main/resources/db/migration/V1__init_schema.sql#L23-L30`, `tasker-backend/src/main/java/com/tasker/model/ServiceCategory.java`
- `id` (SERIAL, PK)
- `name` (VARCHAR(100), UNIQUE, NOT NULL)
- `description` (TEXT)
- `icon_name` (VARCHAR(50), NOT NULL)
- `base_price` (DECIMAL(10,2), DEFAULT 0.00)
- `created_at` (TIMESTAMPTZ)
- *Seed Data:* 13 categories seeded in `V2__seed_categories.sql` and reinforced with 4 core categories in `V4__reseed_missing_categories.sql`.

### 3. `provider_skills` Table / `ProviderSkill` Entity
*File paths:* `tasker-backend/src/main/resources/db/migration/V1__init_schema.sql#L32-L41`, `tasker-backend/src/main/java/com/tasker/model/ProviderSkill.java`
- `id` (UUID, PK)
- `provider_id` (UUID, FK -> `users.id` ON DELETE CASCADE, NOT NULL)
- `category_id` (INTEGER, FK -> `service_categories.id` ON DELETE CASCADE, NOT NULL)
- `experience_years` (INTEGER, DEFAULT 0)
- `hourly_rate` (DECIMAL(10,2))
- `verified` (BOOLEAN, DEFAULT false)
- `created_at` (TIMESTAMPTZ)
- Constraint: `UNIQUE(provider_id, category_id)`

### 4. `jobs` Table / `Job` Entity
*File paths:* `tasker-backend/src/main/resources/db/migration/V1__init_schema.sql#L43-L60`, `tasker-backend/src/main/java/com/tasker/model/Job.java`
- `id` (UUID, PK)
- `client_id` (UUID, FK -> `users.id`, NOT NULL)
- `provider_id` (UUID, FK -> `users.id`, NULLABLE)
- `category_id` (INTEGER, FK -> `service_categories.id`, NOT NULL)
- `title` (VARCHAR(255), NOT NULL)
- `description` (TEXT)
- `status` (VARCHAR(20), NOT NULL, DEFAULT `'REQUESTED'`, CHECK: `'REQUESTED'`, `'MATCHED'`, `'IN_PROGRESS'`, `'COMPLETED'`, `'CANCELLED'`)
- `location` (GEOGRAPHY(Point, 4326), with GIST spatial index)
- `address` (TEXT)
- `scheduled_at`, `started_at`, `completed_at` (TIMESTAMPTZ)
- `estimated_cost`, `final_cost` (DECIMAL(10,2))
- `created_at`, `updated_at` (TIMESTAMPTZ)

### 5. `payments` Table / `Payment` Entity
*File paths:* `tasker-backend/src/main/resources/db/migration/V1__init_schema.sql#L62-L76`, `tasker-backend/src/main/java/com/tasker/model/Payment.java`
- `id` (UUID, PK)
- `job_id` (UUID, FK -> `jobs.id`, NOT NULL)
- `client_id` (UUID, FK -> `users.id`, NOT NULL)
- `provider_id` (UUID, FK -> `users.id`, NULLABLE)
- `amount` (DECIMAL(10,2), NOT NULL)
- `mpesa_checkout_request_id` (VARCHAR(100))
- `mpesa_receipt_number` (VARCHAR(50))
- `status` (VARCHAR(20), NOT NULL, DEFAULT `'PENDING'`, CHECK: `'PENDING'`, `'HELD'`, `'RELEASED'`, `'REFUNDED'`, `'FAILED'`)
- `escrow_held_at`, `released_at` (TIMESTAMPTZ)
- `created_at`, `updated_at` (TIMESTAMPTZ)

### 6. `reviews` Table / `Review` Entity
*File paths:* `tasker-backend/src/main/resources/db/migration/V1__init_schema.sql#L78-L86`, `tasker-backend/src/main/java/com/tasker/model/Review.java`
- `id` (UUID, PK)
- `job_id` (UUID, FK -> `jobs.id`, UNIQUE, NOT NULL)
- `reviewer_id` (UUID, FK -> `users.id`, NOT NULL)
- `reviewee_id` (UUID, FK -> `users.id`, NOT NULL)
- `rating` (INTEGER, NOT NULL, CHECK: `rating BETWEEN 1 AND 5`)
- `comment` (TEXT)
- `created_at` (TIMESTAMPTZ)

---

## 4. API Endpoints

All backend endpoints are prefixed with `/api` (or `/actuator`). Configured in `tasker-backend/src/main/java/com/tasker/security/SecurityConfig.java#L33-L41`.

| Method | Endpoint | Auth Required | Permitted Roles | Controller & Handler | Request DTO / Body | Response DTO / Body |
|---|---|---|---|---|---|---|
| `POST` | `/api/auth/register` | No | Public | `AuthController.register` (`AuthController.java#L23`) | `RegisterRequest` | `AuthResponse` (201 Created) |
| `POST` | `/api/auth/login` | No | Public | `AuthController.login` (`AuthController.java#L28`) | `LoginRequest` | `AuthResponse` (200 OK) |
| `GET` | `/api/categories` | No | Public | `ServiceCategoryController.getAllCategories` (`ServiceCategoryController.java#L22`) | None | `List<ServiceCategoryResponse>` |
| `GET` | `/api/categories/{id}` | No | Public | `ServiceCategoryController.getCategoryById` (`ServiceCategoryController.java#L33`) | None | `ServiceCategoryResponse` |
| `GET` | `/api/users/me` | Yes | Any Authenticated | `UserController.getCurrentUser` (`UserController.java#L27`) | None | `UserResponse` |
| `PUT` | `/api/users/me/location` | Yes | Any Authenticated | `UserController.updateLocation` (`UserController.java#L32`) | `UpdateLocationRequest` | `UserResponse` |
| `PUT` | `/api/users/me/fcm-token` | Yes | Any Authenticated | `UserController.updateFcmToken` (`UserController.java#L38`) | `Map<String, String>` (`{"fcmToken":"..."}`) | `Void` (200 OK) |
| `GET` | `/api/users/providers/{categoryId}/nearby` | Yes | Any Authenticated | `UserController.getNearbyProviders` (`UserController.java#L45`) | Query: `lat`, `lng`, `radiusKm` | `List<ProviderMatchResponse>` |
| `PUT` | `/api/providers/me/availability` | Yes | `PROVIDER` | `ProviderController.updateAvailability` (`ProviderController.java#L24`) | `UpdateAvailabilityRequest` | `ProviderAvailabilityResponse` |
| `GET` | `/api/providers/nearby` | Yes | Any Authenticated | `ProviderController.getNearbyProviders` (`ProviderController.java#L44`) | Query: `categoryId`, `lat`, `lng`, `radiusKm`, `limit` | `List<ProviderMatchResponse>` |
| `POST` | `/api/jobs` | Yes | Any Authenticated | `JobController.createJob` (`JobController.java#L25`) | `CreateJobRequest` | `JobResponse` (201 Created) |
| `GET` | `/api/jobs/{id}` | Yes | Any Authenticated | `JobController.getJob` (`JobController.java#L31`) | None | `JobResponse` |
| `GET` | `/api/jobs/my-jobs` | Yes | Any Authenticated | `JobController.getMyJobs` (`JobController.java#L36`) | None | `List<JobResponse>` |
| `POST` | `/api/jobs/{id}/match` | Yes | Any Authenticated | `JobController.matchProvider` (`JobController.java#L45`) | `Map<String, String>` (`{"providerId":"..."}`) | `JobResponse` |
| `PUT` | `/api/jobs/{id}/start` | Yes | Assigned `PROVIDER` | `JobController.startJob` (`JobController.java#L51`) | None | `JobResponse` |
| `PUT` | `/api/jobs/{id}/complete` | Yes | Assigned `PROVIDER` | `JobController.completeJob` (`JobController.java#L56`) | None | `JobResponse` |
| `PUT` | `/api/jobs/{id}/cancel` | Yes | Any Authenticated | `JobController.cancelJob` (`JobController.java#L61`) | None | `JobResponse` |
| `POST` | `/api/payments/initiate` | Yes | Any Authenticated | `PaymentController.initiatePayment` (`PaymentController.java#L22`) | `InitiatePaymentRequest` | `PaymentResponse` |
| `GET` | `/api/payments/{jobId}` | Yes | Any Authenticated | `PaymentController.getPaymentByJobId` (`PaymentController.java#L28`) | None | `PaymentResponse` |
| `POST` | `/api/mpesa/stk-callback` | No | Public (Daraja Webhook) | `MpesaCallbackController.handleSTKCallback` (`MpesaCallbackController.java#L19`) | Daraja JSON Payload | `Void` (200 OK) |
| `POST` | `/api/mpesa/b2c-result` | No | Public (Daraja Webhook) | `MpesaCallbackController.handleB2CResult` (`MpesaCallbackController.java#L25`) | Daraja JSON Payload | `Void` (200 OK) |
| `POST` | `/api/mpesa/b2c-timeout` | No | Public (Daraja Webhook) | `MpesaCallbackController.handleB2CTimeout` (`MpesaCallbackController.java#L31`) | Daraja JSON Payload | `Void` (200 OK) |
| `GET` | `/api/admin/providers/unverified-skills` | Yes | `ADMIN` | `AdminController.getUnverifiedSkills` (`AdminController.java#L24`) | None | `List<ProviderSkill>` |
| `PUT` | `/api/admin/providers/skills/{skillId}/verify` | Yes | `ADMIN` | `AdminController.verifySkill` (`AdminController.java#L29`) | None | `ProviderSkill` |
| `GET` | `/api/admin/stats` | Yes | `ADMIN` | `AdminController.getDashboardStats` (`AdminController.java#L34`) | None | `Map<String, Long>` |
| `GET` | `/actuator/health` | No | Public | Spring Boot Actuator | None | Health JSON (`{"status":"UP"}`) |

### Missing Endpoints
- **No Review Controller:** `ReviewService.java` implements `createReview` and `getReviewsByProvider`, but there is **no REST controller** exposing them. Reviews cannot be submitted or fetched via HTTP.
- **No Escrow Release / Payout Endpoint:** `PaymentService.releasePayment` exists, but is not exposed in `PaymentController` or called upon job completion.
- **No Provider Skills Management:** No endpoint exists for a provider to register or update their own skills (only admin verification exists).

---

## 5. How Auth Works

### Backend Auth Flow
1. **Password Hashing:** Passwords are encrypted using `BCryptPasswordEncoder` (`tasker-backend/src/main/java/com/tasker/security/SecurityConfig.java#L47-L49`).
2. **Registration:**
   - Handled in `AuthService.register()` (`tasker-backend/src/main/java/com/tasker/service/AuthService.java#L78-L109`).
   - Rejects `ADMIN` role from registration; only `CLIENT` or `PROVIDER` allowed.
   - Requires valid email syntax and validates uniqueness of both `email` and `phoneNumber`.
   - Persists user and returns an `AuthResponse` containing a newly minted JWT token.
3. **Login:**
   - Handled in `AuthService.login()` (`tasker-backend/src/main/java/com/tasker/service/AuthService.java#L111-L127`).
   - Verifies email and matches raw password against `passwordHash`.
   - Generates JWT via `JwtTokenProvider.generateToken()`.
4. **JWT Structure:**
   - Subject: `user.getId().toString()` (`UUID`).
   - Custom claim: `role` (`CLIENT`, `PROVIDER`, or `ADMIN`).
   - Signing Algorithm: HMAC-SHA256 using key derived from `app.jwt.secret`.
   - Expiration: Configurable via `app.jwt.expiration-ms` (defaults to 86,400,000 ms / 24 hours).
   - In `prod` profile, `JwtTokenProvider.validateSecret()` fails startup if `app.jwt.secret` is missing or under 32 bytes (256 bits).
5. **Request Authorization:**
   - `JwtAuthenticationFilter` (`tasker-backend/src/main/java/com/tasker/security/JwtAuthenticationFilter.java#L34-L58`) intercepts every incoming HTTP request.
   - Extracts Bearer token from header `Authorization: Bearer <token>`.
   - Validates token signature and expiration.
   - Extracts `userId`, loads the user from `UserRepository`, builds a `UserPrincipal`, and populates `SecurityContextHolder.getContext().setAuthentication(...)`.
   - Role authority is set as `ROLE_<ROLE_NAME>` (e.g. `ROLE_CLIENT`, `ROLE_PROVIDER`, `ROLE_ADMIN`).

### Frontend Auth Flow
1. **Storage:**
   - JWT token stored securely using `flutter_secure_storage` under key `auth_token` (`tasker-frontend/lib/core/storage/secure_storage_service.dart#L10`).
2. **State Management:**
   - `AuthController` (`tasker-frontend/lib/features/auth/presentation/controllers/auth_controller.dart`) manages current user state as `AsyncNotifier<User?>`.
   - On application startup, `checkAuthStatus()` reads token from storage and calls `/api/users/me`. If invalid or expired, storage is cleared and user is set to `null`.
3. **Network Interception:**
   - `AuthInterceptor` (`tasker-frontend/lib/core/network/auth_interceptor.dart#L13-L17`) attaches `Authorization: Bearer <token>` to all outgoing Dio requests.
   - On HTTP 401 response, it automatically purges the stored token (`tasker-frontend/lib/core/network/auth_interceptor.dart#L22-L26`).
4. **Route Guarding:**
   - GoRouter redirect hook (`tasker-frontend/lib/app/router.dart#L21-L36`) monitors `authControllerProvider`.
   - If user is unauthenticated and attempts to visit a protected route, redirects to `/login`.
   - If user is authenticated and attempts to visit `/login` or `/register`, redirects to `/client-home` or `/provider-home` based on role.

---

## 6. How Matching Works

Matching finds available providers offering a given service category within a specified geographical distance of the client or job location.

### Spatial Query Mechanism
- Implemented in `UserRepository.findNearbyAvailableProvidersByCategory` (`tasker-backend/src/main/java/com/tasker/repository/UserRepository.java#L21-L46`) using PostGIS native SQL:
  ```sql
  SELECT u.id AS provider_id, u.full_name AS full_name, u.phone_number AS phone_number,
         u.rating AS rating, u.total_reviews AS total_reviews, u.profile_image_url AS profile_image_url,
         ps.hourly_rate AS hourly_rate, ps.experience_years AS experience_years, ps.verified AS verified,
         ST_Distance(u.location, ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)::geography) AS distance_meters
  FROM users u
  JOIN provider_skills ps ON u.id = ps.provider_id
  WHERE u.role = 'PROVIDER'
    AND u.is_available = true
    AND ps.category_id = :categoryId
    AND u.location IS NOT NULL
    AND ST_DWithin(u.location, ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)::geography, :radiusMeters)
  ORDER BY distance_meters ASC
  LIMIT :limit;
  ```
- Uses GIST spatial index on `users(location)`.
- Validations in `LocationService.java#L78-L102`: Category ID > 0, latitude within `[-90, 90]`, longitude within `[-180, 180]`, radius `1..100 km` (default 10 km via `app.search.default-radius-km`), limit `1..100` (default 50).
- Results returned via `NearbyProviderProjection` (`tasker-backend/src/main/java/com/tasker/repository/NearbyProviderProjection.java`) and mapped to `ProviderMatchResponse` converting meters to kilometers.

### Job Assignment (`matchProvider`)
- Backend method `JobService.matchProvider(jobId, providerId)` (`tasker-backend/src/main/java/com/tasker/service/JobService.java#L80-L98`):
  - Validates job exists and is in `REQUESTED` status.
  - Assigns `provider` to job and updates status to `MATCHED`.
  - Dispatches FCM push notification to provider via `NotificationService.sendNotification()`.

### Discrepancies and Frontend Integration Bugs
1. **Broken Deserialization:** In `tasker-frontend/lib/features/jobs/data/datasources/job_remote_ds.dart#L65-L71`, `getNearbyProviders` maps response items to `User.fromJson(e)`. The backend returns `ProviderMatchResponse` containing `providerId`, whereas `User.fromJson` expects `id`. Consequently, `user.id` is parsed as empty string `""`, and `distanceKm`, `hourlyRate`, and `verified` are discarded.
2. **Circular Navigation Loop:** In `tasker-frontend/lib/features/jobs/presentation/screens/create_job_screen.dart#L88`, submitting the form creates a job and navigates to `/providers/nearby/$categoryId`. In `tasker-frontend/lib/features/jobs/presentation/screens/provider_match_screen.dart#L198`, pressing "Select Provider" navigates to `/jobs/create/$categoryId?providerId=${provider.id}`. This loops back to job creation!
3. **Orphaned Match Endpoint:** `JobRemoteDs.matchProvider(jobId, providerId)` exists in `tasker-frontend/lib/features/jobs/data/datasources/job_remote_ds.dart#L32`, but is **never called** by any controller or UI screen.

---

## 7. How Payments Work (or Whether They Are Only Stubbed)

Payments are architected around an escrow model using Safaricom Daraja M-Pesa. However, key sections are **stubbed, incomplete, or bypassed with fallback mocks**.

### 1. Escrow Initiation (STK Push)
- Triggered by `POST /api/payments/initiate` (`tasker-backend/src/main/java/com/tasker/controller/PaymentController.java#L22`).
- Calls `PaymentService.initiatePayment()` (`tasker-backend/src/main/java/com/tasker/service/PaymentService.java#L35-L62`).
- Validates job is not `COMPLETED` or `CANCELLED`.
- Calls `MpesaService.initiateSTKPush()` which sends an HTTP POST to `https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest`.
- Persists `Payment` record with status `PENDING` and saves `mpesaCheckoutRequestId`.
- **Stubbed Fallbacks in `MpesaService`:**
  - In `getOAuthToken()` (`tasker-backend/src/main/java/com/tasker/service/MpesaService.java#L43-L46`): On exception, catches and returns `"dummy-token"`.
  - In `initiateSTKPush()` (`tasker-backend/src/main/java/com/tasker/service/MpesaService.java#L79-L84`): On any exception (e.g., Daraja sandbox unreachable, invalid credentials), catches and returns a simulated response:
    ```java
    Map<String, Object> fallback = new HashMap<>();
    fallback.put("CheckoutRequestID", "dummy-checkout-" + UUID.randomUUID().toString());
    fallback.put("ResponseCode", "0");
    return fallback;
    ```
    This masks all network and configuration failures as successes during testing.

### 2. STK Callback Handling (Escrow Held)
- Endpoint: `POST /api/mpesa/stk-callback` (`tasker-backend/src/main/java/com/tasker/controller/MpesaCallbackController.java#L19`).
- Handled in `PaymentService.handleSTKCallback()` (`tasker-backend/src/main/java/com/tasker/service/PaymentService.java#L64-L100`).
- If `ResultCode == 0`:
  - Payment status becomes `HELD`.
  - Sets `escrowHeldAt = LocalDateTime.now()`.
  - **Stub:** Hardcoded receipt: `payment.setMpesaReceiptNumber("DUMMY_RECEIPT"); // Placeholder` (`PaymentService.java#L78`). Parsing logic for `CallbackMetadata` is unwritten.
  - Side effect: Automatically updates `job.setStatus(JobStatus.IN_PROGRESS)` and sends push notifications to client and provider (`PaymentService.java#L80-L86`).
- **Silent Exception Swallowing:** The method body is wrapped in `catch (Exception e) { // Log error }` without rethrowing or logging details.

### 3. Escrow Release / Payout (B2C)
- Method `PaymentService.releasePayment(UUID jobId)` exists in `tasker-backend/src/main/java/com/tasker/service/PaymentService.java#L102-L119`.
- Verifies payment is `HELD`, retrieves provider phone number, and calls `mpesaService.initiateB2CPayment()`.
- Marks payment as `RELEASED` with `releasedAt = now()`.
- **Orphaned Method:** `releasePayment` is **never called** by `JobService.completeJob()` or exposed by `PaymentController`. Escrowed funds are never released.
- **Stubbed Daraja B2C Payload:**
  - `MpesaService.initiateB2CPayment()` (`tasker-backend/src/main/java/com/tasker/service/MpesaService.java#L87-L113`) hardcodes invalid sandbox dummy credentials:
    `payload.put("SecurityCredential", "dummy-security-credential");`
    `payload.put("InitiatorName", "APIUser");`
    Daraja B2C requires encrypting the initiator password using Safaricom's public X.509 certificate.
  - On failure, it catches and returns a dummy conversation ID (`dummy-conv-...`).
  - `PaymentService.handleB2CCallback()` (`PaymentService.java#L122-L124`) has an **empty body** (`// Handle B2C result`).
  - `MpesaCallbackController.handleB2CTimeout()` (`MpesaCallbackController.java#L31-L34`) is an empty stub returning 200 OK.

### 4. Escrow Refunds
- `REFUNDED` exists in the schema check constraint and `PaymentStatus` enum.
- There is **zero code** in the entire codebase implementing refund initiation or B2C refund transactions for cancelled jobs.

### 5. Frontend Payment Flow
- `PaymentScreen` (`tasker-frontend/lib/features/payment/presentation/screens/payment_screen.dart`) initiates payment and shows a bottom sheet `MpesaPromptDialog` (`tasker-frontend/lib/features/payment/presentation/widgets/mpesa_prompt_dialog.dart`).
- When the user taps "Done", the dialog closes and the screen pops back. The frontend **does not poll** `GET /api/payments/{jobId}` or listen to webhooks to verify whether the M-Pesa transaction was confirmed or failed.

---

## 8. How the Frontend Talks to the Backend

### Client Networking Stack
- **Library:** Dio 5.7.0 (`tasker-frontend/lib/core/network/dio_client.dart#L8-L31`).
- **Timeouts:** 15 seconds connect timeout, 15 seconds receive timeout.
- **Base URL:**
  *File path:* `tasker-frontend/lib/core/constants/api_endpoints.dart#L4`
  ```dart
  static String get baseUrl => Platform.isAndroid ? 'http://10.0.2.2:8080/api/' : 'http://localhost:8080/api/';
  ```
  *Limitation:* Hardcoded to emulator and localhost. There is no build-time or runtime environment configuration (such as `String.fromEnvironment('API_BASE_URL')` or `.env`) for pointing to production Render URLs.

### Authentication & Token Propagation
- `AuthInterceptor` (`tasker-frontend/lib/core/network/auth_interceptor.dart`):
  - In `onRequest`, reads JWT from `SecureStorageService` and injects header: `Authorization: Bearer <token>`.
  - In `onError`, catches HTTP 401 and deletes the token from secure storage.

### Layered Flow
1. **Screen / UI:** User action triggers a method on an `AsyncNotifier` controller.
2. **Controller:** Calls methods on a remote datasource (`*RemoteDs`).
3. **Datasource:** Invokes Dio against endpoint constants defined in `ApiEndpoints`.
4. **State Update:** Controller updates its `AsyncValue` state (`AsyncData`, `AsyncError`, or `AsyncLoading`), prompting UI rebuilds.

### Architecture Divergences and Gaps
- **Model Type Divergence:**
  - `Job.categoryId`: Backend `JobResponse.java#L14` sends `Integer categoryId`. In `tasker-frontend/lib/features/jobs/domain/models/job.dart#L44`, it is deserialized as `categoryId: json['categoryId'] ?? ''`. If the backend returns `1`, Dart strong mode will throw a runtime `TypeError` (`int is not a subtype of String`).
- **Uncalled Backend Endpoints:**
  - `PUT /api/users/me/location`: Defined in `ApiEndpoints.updateLocation`, but never called in any frontend service or controller. User location is never synced to the database after login.
  - `PUT /api/users/me/fcm-token`: Defined in `ApiEndpoints.updateFcmToken`, but never called in any frontend service or controller.
  - `PUT /api/providers/me/availability`: On `ProviderHomeScreen` (`tasker-frontend/lib/features/home/presentation/screens/provider_home_screen.dart#L72`), the online/offline switch only toggles local boolean `_isOnline` with `setState()`. The backend endpoint is never called.
  - `POST /api/jobs/{id}/match`: Defined in `JobRemoteDs.matchProvider`, never called by any UI widget.
- **Missing Features in Frontend:**
  - No reviews UI or networking.
  - No admin UI or networking.
  - No map integration: `google_maps_flutter` is declared in `pubspec.yaml`, but `GoogleMap` widget is **never instantiated** anywhere in the code.
  - No geocoding: `geocoding` is declared in `pubspec.yaml`, but never imported or used. Location address falls back to hardcoded string `'Current Location'`.
  - Hardcoded Provider Stats: On `ProviderHomeScreen`, `StatsCard` values are hardcoded strings (`"24"` completed, `"4.9"` rating).

---

## 9. What I Could Not Determine

1. **Render PostGIS Compatibility on Managed DB:** While `render.yaml` specifies `postgresMajorVersion: "16"`, it cannot be verified from the codebase whether Render's starter PostgreSQL instance permits non-superuser activation of `CREATE EXTENSION postgis;` or whether a custom PostGIS-enabled template/extension install is required. *(Marked: Unverified)*.
2. **Production Daraja Credentials & Certificate:** The repository contains only sandbox dummy keys and default passwords. The actual Safaricom Daraja B2C public certificate, production shortcode, and production initiator credentials could not be determined. *(Marked: Unverified)*.
3. **Firebase Configuration & FCM Operational Status:** While `FirebaseConfig.java` is written, no Firebase service account JSON is present (rightfully gitignored), and no FCM sender ID or APNs configuration exists in Flutter platform folders (`google-services.json` and `GoogleService-Info.plist` are gitignored and absent). Whether push notifications have ever been validated end-to-end remains unverified. *(Marked: Unverified)*.
4. **Google Maps API Key:** The Android manifest references `${MAPS_API_KEY}`, but no Google Cloud project configuration, iOS Google Maps API key, or active map widget implementation exists. *(Marked: Unverified)*.
5. **Admin Access Workflow:** While an admin user can be bootstrapped on backend startup via `ADMIN_EMAIL` and `ADMIN_PASSWORD`, there is no web console, Flutter admin screen, or documented tooling for how administrative reviews and skill verifications are performed in practice. *(Marked: Unverified)*.
