# Tasker - Home Services Marketplace

Tasker is a full-stack home services marketplace app (similar to TaskRabbit or Uber for home services). It allows Clients to request services (Plumbing, Cleaning, etc.) and Matches them with nearby Providers.

## Tech Stack
* **Backend**: Java 21, Spring Boot 3.4, Spring Security (JWT), Hibernate Spatial
* **Database**: PostgreSQL with PostGIS extension (for location-based queries)
* **Frontend**: Flutter, Riverpod (State Management), GoRouter
* **Integrations**: Daraja M-Pesa API (Payments), Firebase Cloud Messaging (Push Notifications), Google Maps

---

## 🚀 How to Run the Project Locally

To run this project on your machine, you will need to run the Database, the Backend, and the Frontend separately.

### Prerequisites
* [Docker](https://docs.docker.com/get-docker/) (for running PostGIS easily)
* [Java 21](https://adoptium.net/) & Maven
* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* (Optional) Firebase project for Push Notifications
* (Optional) Safaricom Daraja Sandbox Account for M-Pesa

### 1. Start the Database
The backend requires a PostgreSQL database with the PostGIS extension for spatial queries. The easiest way is via Docker:
```bash
docker run --name tasker-db \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_DB=tasker_dev \
  -p 5432:5432 \
  -d postgis/postgis:16-3.4
```

### 2. Run the Spring Boot Backend
The backend uses Flyway to automatically create the tables and seed dummy users (e.g., `dan@example.com` / `password123`) when it starts up.

```bash
cd tasker-backend

# Run with the 'dev' profile (which connects to the local Docker database)
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

**Environment Variables (Optional):**
If you want to test M-Pesa or Firebase, you can pass the following environment variables before running the backend:
* `MPESA_CONSUMER_KEY`, `MPESA_CONSUMER_SECRET`, `MPESA_PASSKEY`, `MPESA_CALLBACK_BASE_URL` (Requires Ngrok for local testing)
* `JWT_SECRET` (For overriding the default dev JWT secret)

For Firebase, generate a service account JSON and place it in the project root, then update `app.firebase.config.path` in `application.yml`.

### 3. Run the Flutter Frontend
Before running the frontend, you must add your Google Maps API key to the Android manifest.

1. Open `tasker-frontend/android/app/src/main/AndroidManifest.xml`.
2. Find the `<meta-data android:name="com.google.android.geo.API_KEY" .../>` tag and replace `YOUR_API_KEY_HERE` with your actual Google Maps API key.
3. (Optional) Run `flutterfire configure` if you want to set up your own Firebase project for push notifications.

Run the app:
```bash
cd tasker-frontend
flutter pub get
flutter run
```

### 4. Test Accounts
The database is pre-seeded with users centered around Ongata Rongai. All passwords are `password123`.
* **Client**: `alice@example.com`
* **Provider (Plumbing/Electrical)**: `dan@example.com`
* **Provider (Cleaning)**: `eve@example.com`

---

## Deployment
A `render.yaml` blueprint is included in the `tasker-backend` folder for easy 1-click deployment to [Render](https://render.com), which will provision both the Web Service (Docker runtime) and a managed PostgreSQL database.
