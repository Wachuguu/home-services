Home services— Local Services Marketplace

A full-stack two-sided marketplace connecting **Clients** with skilled **Providers** for 13 home service categories, with geolocation matching, escrow payments via M-Pesa, and a premium dark-mode mobile UI.

---

## Tech Stack

| Layer | Technology |
|:---|:---|
| **Backend** | Java 21, Spring Boot 3.4.2, Hibernate Spatial, Flyway |
| **Database** | PostgreSQL 16 + PostGIS (geospatial queries) |
| **Auth** | JWT Bearer tokens, BCrypt, Spring Security |
| **Payments** | M-Pesa Daraja API (STK Push + B2C escrow) |
| **Notifications** | Firebase Cloud Messaging (FCM) |
| **Frontend** | Flutter 3.x |
| **State Mgmt** | Riverpod (manual AsyncNotifierProvider) |
| **Navigation** | GoRouter 14.x |
| **HTTP** | Dio 5.x with JWT interceptor |
| **Maps** | Google Maps Flutter |
| **Deployment** | Render (Docker + Render.yaml blueprint) |

---

## Project Structure

```
tasker/
├── tasker-backend/     # Spring Boot REST API
└── tasker-frontend/    # Flutter mobile app
```

---

## Service Categories (13)

| # | Category | Base Price (KES) |
|:---|:---|:---|
| 1 | Plumbing | 1,500 |
| 2 | Landscaping | 2,000 |
| 3 | Laundry | 500 |
| 4 | Furniture Assembly | 1,200 |
| 5 | Mounting & Installation | 800 |
| 6 | Electrical Repairs | 1,800 |
| 7 | Moving & Heavy Lifting | 3,000 |
| 8 | Carpentry | 2,500 |
| 9 | House Painting | 2,000 |
| 10 | Appliance Repair | 1,500 |
| 11 | Deep Cleaning | 1,800 |
| 12 | Roofing & Gutter Maintenance | 3,500 |
| 13 | Pest Control | 2,500 |

---

## Getting Started

### Prerequisites
- Java 21 (OpenJDK)
- Maven 3.9+
- PostgreSQL 16 with PostGIS extension
- Flutter 3.x SDK
- (Optional) Firebase project for push notifications

### Backend

```bash
# 1. Create the database
createdb tasker_dev

# 2. Install PostGIS (Ubuntu)
sudo apt install postgresql-16-postgis-3

# 3. Run (Flyway auto-runs migrations on startup)
cd tasker-backend
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

API available at: `http://localhost:8080/api`

### Frontend

```bash
cd tasker-frontend
flutter pub get
flutter run
```

> **Note:** Update `lib/core/constants/api_endpoints.dart` with your backend URL.
> Add your Google Maps API key to `android/app/src/main/AndroidManifest.xml`.

---

## Environment Variables (Backend)

| Variable | Description |
|:---|:---|
| `SPRING_DATASOURCE_URL` | JDBC PostgreSQL URL |
| `SPRING_DATASOURCE_USERNAME` | DB username |
| `SPRING_DATASOURCE_PASSWORD` | DB password |
| `JWT_SECRET` | 256-bit JWT signing secret |
| `MPESA_CONSUMER_KEY` | Daraja API consumer key |
| `MPESA_CONSUMER_SECRET` | Daraja API consumer secret |
| `MPESA_PASSKEY` | Daraja STK Push passkey |
| `MPESA_SHORTCODE` | M-Pesa shortcode / paybill |
| `MPESA_CALLBACK_BASE_URL` | Public URL for M-Pesa callbacks |

---

## M-Pesa Payment Flow

```
Client pays → STK Push → PIN entry → Funds HELD (escrow)
Provider completes job → B2C payout → Funds RELEASED to provider
```

---

## Deployment (Render)

```bash
# Uses render.yaml blueprint
# 1. Push to GitHub
# 2. Connect repo in Render dashboard
# 3. Render auto-detects render.yaml and deploys
```

---

## Test Seed Data

9 test users pre-seeded around **Ongata Rongai** (lat: -1.3958, lng: 36.7620):
- **3 Clients**: Alice, Bob, Carol
- **6 Providers**: Dan (Plumbing/Electrical), Eve (Cleaning/Laundry), Frank (Carpentry), Grace (Painting), Hassan (Moving/Roofing), Irene (Appliance Repair)
- **1 Admin**: admin@tasker.com

All test passwords: `password123`

---

## API Endpoints

```
POST   /api/auth/register
POST   /api/auth/login
GET    /api/users/me
PUT    /api/users/me/location
GET    /api/categories
POST   /api/jobs
GET    /api/jobs/my-jobs
POST   /api/jobs/{id}/match
PUT    /api/jobs/{id}/start
PUT    /api/jobs/{id}/complete
PUT    /api/jobs/{id}/cancel
GET    /api/users/providers/{catId}/nearby?lat=&lng=&radiusKm=
POST   /api/payments/initiate
GET    /api/payments/{jobId}
GET    /api/admin/providers/unverified-skills    (ADMIN)
PUT    /api/admin/providers/skills/{id}/verify  (ADMIN)
```

---

## License

MIT
