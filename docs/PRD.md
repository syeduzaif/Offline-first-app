# Product Requirements Document (PRD)
## Offline-First Product Catalog App

**Version:** 1.0
**Date:** March 2026
**Platform:** Android (iOS ready)

---

## 1. Overview

A mobile product catalog application built with Flutter that allows users to browse, search, create, edit, and delete products — fully functional with or without an internet connection. All data mutations are queued locally and automatically synced to the remote API when connectivity is restored.

---

## 2. Goals

- Users can use the app without interruption regardless of network state.
- Changes made offline are never lost and are synced automatically when online.
- Users have full visibility into the sync state of their data.

---

## 3. Users

Single-user app. No authentication. Intended for internal catalog management.

---

## 4. Features

### 4.1 Product Catalog

- Display a paginated list of products fetched from the remote API and cached locally.
- Each product card shows: thumbnail, title, category, price, rating, stock, and sync status badge.
- Pull-to-refresh to fetch latest data from the remote API.
- Infinite scroll pagination (20 products per page).
- Works fully offline using locally cached data.

### 4.2 Search

- Real-time search by product title.
- Search results are streamed from the local database.

### 4.3 Category Filter

- Filter products by category using horizontally scrollable chips.
- Categories are fetched from the API and cached locally.
- "All" chip resets the filter.

### 4.4 Product Detail

- View full product information: images gallery, title, brand, category, price, discount, rating, stock, description.
- Navigate to edit from the detail screen.
- Delete product with confirmation.

### 4.5 Add Product

- Form with fields: title (required), description, price, brand, stock, category (dropdown).
- On save: stored locally immediately, queued for API sync, sync attempted instantly if online.
- Snackbar confirmation on success.
- Navigates back automatically after save.

### 4.6 Edit Product

- Pre-filled form with existing product data.
- On save: updated locally immediately, queued for API sync, sync attempted instantly if online.
- Snackbar confirmation on success.
- Navigates back automatically after save.

### 4.7 Delete Product

- Soft-delete locally (marked `isDeleted = true`).
- Queued as a delete operation in the sync queue.
- Hard-deleted locally after successful API confirmation.

### 4.8 Sync Queue

- Dedicated tab showing all pending, in-progress, completed, and failed sync operations.
- Each operation card shows: type (create/update/delete), entity ID, status, retry count, timestamp, and error message if failed.
- "Sync Now" button to manually trigger synchronisation.
- "Clear Completed" button to remove completed operations from the list.
- Retry button on failed operations.
- Badge on the nav tab shows count of pending/failed operations.

### 4.9 Connectivity Banner

- A banner at the top of the Products screen indicates when the app is offline.
- Disappears automatically when connectivity is restored.

### 4.10 Background Sync

- Periodic background sync every 15 minutes using WorkManager (Android).
- Only runs when network is connected.
- Processes all pending queue operations.

---

## 5. Sync Behaviour

| Scenario | Behaviour |
|---|---|
| Online, user saves | Saved locally → enqueued → synced immediately |
| Offline, user saves | Saved locally → enqueued → stays pending |
| Connectivity restored | All pending operations synced automatically |
| API call fails | Marked as failed, retry count incremented |
| 3 failures | Product marked as `failed` sync status, stops retrying |
| User retries manually | Reset to pending, sync triggered |

---

## 6. Navigation

```
MainView (bottom nav)
├── Tab 1: Products
│   ├── ProductDetailView
│   │   └── EditProductView
│   └── AddProductView
└── Tab 2: Sync Queue
```

---

## 7. Non-Functional Requirements

- App must launch and be usable within 2 seconds on cached data.
- Local DB operations must not block the UI thread.
- API timeout: 15 seconds for connect and receive.
- Retry policy: 3 attempts with exponential backoff (1s, 2s, 4s).
- Pagination: 20 items per page.
- Background sync interval: 15 minutes minimum (OS may defer).
