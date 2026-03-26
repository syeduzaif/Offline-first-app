# External Integrations

**Analysis Date:** 2026-03-26

## APIs & External Services

**Product Data API:**
- DummyJSON REST API (`https://dummyjson.com`) - Mock product catalog API; provides paginated product listing, search, category filtering, and CRUD endpoints
  - SDK/Client: `dio ^5.4.0` via `lib/data/remote/api_client.dart`
  - Auth: None — public API, no authentication required
  - Note: Mutations (POST/PUT/DELETE) return success responses but do not persist server-side; this is by design for offline-first demonstration

**Endpoints consumed:**

| Method | Path | Usage |
|---|---|---|
| GET | `/products` | Paginated product list (`limit`, `skip`) |
| GET | `/products/:id` | Single product fetch |
| GET | `/products/search` | Full-text search (`q`, `limit`, `skip`) |
| GET | `/products/category/:slug` | Category-filtered listing |
| POST | `/products/add` | Create product (sync queue outbox) |
| PUT | `/products/:id` | Update product (sync queue outbox) |
| DELETE | `/products/:id` | Delete product (sync queue outbox) |
| GET | `/products/categories` | Fetch all category slugs |

**HTTP client configuration** (`lib/data/remote/api_client.dart`):
- Connect timeout: 15 seconds
- Receive timeout: 15 seconds
- Retry: 3 attempts, exponential backoff 1s → 2s → 4s via `dio_smart_retry`

## Data Storage

**Databases:**
- SQLite via Drift ORM
  - File location: `{ApplicationDocumentsDirectory}/offline_first.sqlite`
  - Connection opened in: `lib/data/local/database.dart` (`_openConnection()`)
  - Client: Drift `^2.24.0` with `NativeDatabase.createInBackground`
  - Schema version: 1 (no migrations defined beyond `onCreate`)
  - Tables: `products`, `sync_queue`, `categories`
  - DAOs: `ProductsDao` (`lib/data/local/daos/products_dao.dart`), `SyncQueueDao` (`lib/data/local/daos/sync_queue_dao.dart`), `CategoriesDao` (`lib/data/local/daos/categories_dao.dart`)

**File Storage:**
- Local filesystem only — product thumbnail/image URLs stored as strings; actual images fetched and cached at runtime by `cached_network_image`

**Caching:**
- Network images: `cached_network_image ^3.4.1` — automatic disk cache for product thumbnails and gallery images
- Structured data: All API responses written to SQLite immediately after fetch (cache-then-serve pattern)

## Authentication & Identity

**Auth Provider:**
- None — the app is explicitly single-user with no authentication (per PRD: "Single-user app. No authentication.")

## Background Tasks

**Android WorkManager:**
- Package: `workmanager ^0.9.0`
- Task name: `offline-first-sync`
- Unique name: `backgroundSync`
- Frequency: 15 minutes (minimum; OS may defer)
- Network constraint: `NetworkType.connected`
- Callback dispatcher: `callbackDispatcher()` in `lib/main.dart` — annotated `@pragma('vm:entry-point')`, runs in an independent Dart isolate
- The background isolate creates its own `AppDatabase`, `ApiClient`, `ConnectivityService`, and `SyncService` instances — fully isolated from foreground app state

## Connectivity Detection

- Package: `connectivity_plus ^6.1.4`
- Wrapper: `lib/services/connectivity_service.dart`
- Behavior: Maintains reactive `isOnline` boolean; broadcasts changes on stream; debounced by value comparison to avoid duplicate events
- Drives sync trigger: `SyncService` subscribes to `ConnectivityService.onConnectivityChanged` and calls `syncAll()` on each transition to online

## Monitoring & Observability

**Error Tracking:**
- None — no crash reporting or error tracking service integrated

**Logs:**
- No structured logging library; sync errors are stored in the `sync_queue` table's `errorMessage` column for user visibility in `lib/ui/views/sync_queue/sync_queue_view.dart`

## CI/CD & Deployment

**Hosting:**
- Not configured — no deployment pipeline present

**CI Pipeline:**
- None detected

## Environment Configuration

**Required env vars:**
- None — the project has no `.env` files and no runtime environment variables
- API base URL is a compile-time constant in `lib/data/remote/api_constants.dart`:
  ```dart
  static const String baseUrl = 'https://dummyjson.com';
  ```

**Secrets location:**
- No secrets required for this project

## Webhooks & Callbacks

**Incoming:**
- None

**Outgoing:**
- None — all remote communication is request/response via `ApiClient`; no webhooks or push notifications

---

*Integration audit: 2026-03-26*
