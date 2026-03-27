# 📘 Flutter Offline-First Architecture Guide (For AI Agents & Developers)

## 🎯 Purpose

This document defines a **strict, clean, and scalable architecture** for building a Flutter app using:

* Riverpod (state management)
* Clean Architecture
* Offline-first approach (with sync & queue)

The goal is to ensure:

* Clean and maintainable code
* High performance
* Predictable data flow
* No over-engineering

---

# 🧱 1. Core Principles (MANDATORY)

1. **Keep code simple and readable**
2. **Avoid over-engineering**
3. **One responsibility per class**
4. **Follow strict layer separation**
5. **Local DB is the first source of truth**
6. **All write operations must go through queue**

---

# 🧭 2. Data Flow (STRICT)

```
UI → Controller → UseCase → Repository → DataSources
```

### ❌ NEVER:

* UI calling API directly
* UI accessing database
* Controller calling API directly

---

# 📂 3. Project Structure

```
lib/
├── app/
├── core/
├── services/
├── features/
```

---

# 🧩 4. Feature Structure (MANDATORY)

Each feature must follow:

```
feature/
├── data/
│   ├── models/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   ├── repositories_impl/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   ├── usecases/
│
├── presentation/
│   ├── screens/
│   ├── widgets/
│   ├── controllers/
│
├── providers/
```

---

# 🧠 5. Layer Responsibilities

## 🎨 UI (Presentation Layer)

* Only renders UI
* No business logic
* Uses Riverpod to read state

---

## ⚙️ Controller (Riverpod)

* Manages UI state
* Calls usecases
* No heavy logic

---

## 🧠 UseCase

* Contains business logic
* One usecase = one responsibility

---

## 📦 Repository (Interface)

* Defines contract for data

---

## 🔌 Repository Implementation

* Handles:

  * API calls
  * Local DB
  * Queue system

---

## 💾 DataSources

* Local → database
* Remote → API

---

# 🔄 6. Offline-First Rules

## 📥 Read Flow

```
1. Load from Local DB
2. Fetch from API (background)
3. Update DB
4. UI updates automatically
```

---

## 📤 Write Flow

```
1. Save to Local DB
2. Add to Queue
3. Update UI instantly
4. Sync in background
```

---

# 📦 7. Queue System Rules

Every write operation must:

* Be stored in queue
* Be retried if failed

### Queue Model:

```
id
feature
operationType (create/update/delete)
payload
status
retryCount
createdAt
```

---

# 🔄 8. Sync System Rules

* Runs automatically
* Triggered on:

  * Internet connection
  * App start
  * User actions

### Retry Logic:

* Use exponential backoff
* Max retry limit (e.g. 5)

---

# 🧠 9. Riverpod Guidelines

## Use Correct Provider Types

* AsyncNotifier → async data (API/DB)
* Notifier → UI state
* Provider → dependency injection

---

## Controller Rules

* One controller per screen/feature
* Keep logic minimal
* Do not call API directly

---

## Performance Rule

Use selective watching:

```
ref.watch(provider.select(...))
```

Avoid watching entire state unnecessarily.

---

# 💾 10. Database Rules

* Use local DB as primary source
* Keep models simple
* Avoid deep nested objects
* Use IDs instead of object references

---

## Performance

* Query only required data
* Avoid large full-table reads
* Use pagination where needed

---

# 🌐 11. API Rules

* Always map:

  ```
  DTO → Entity
  ```
* Never expose API models to UI
* Handle errors gracefully

---

# 🔐 12. Security Rules

* Store tokens securely
* Do not log sensitive data
* Avoid plain text storage

---

# ⚙️ 13. Services Layer Responsibilities

Located in `services/`

Handles:

* API client
* Sync logic
* Queue processing
* Connectivity

---

# 🧪 14. Error Handling

Use structured error handling:

* Domain → Failure
* Data → Exception

Never throw generic exceptions.

---

# 🎨 15. UI Performance Rules

* Use const widgets
* Break UI into small components
* Use lazy loading (ListView.builder)

---

# ⚠️ 16. Things to Avoid

* Mixing layers
* Large controllers
* Direct API calls in UI
* Skipping queue for writes
* Over-complicating simple logic

---

# 🧱 17. Code Style Rules

* File size ≤ 400 lines
* Clear naming:

  * `user_controller.dart`
  * `get_users_usecase.dart`
* One class = one responsibility

---

# 🧪 18. Testing Strategy

* Test usecases
* Test repositories
* Mock API and DB

---

# 🚀 19. Development Workflow

1. Start with feature
2. Create structure
3. Implement:

   * Entity
   * Usecase
   * Repository
   * Controller
4. Connect UI
5. Add offline + queue logic

---

# ✅ 20. Final Checklist (Before PR)

* [ ] No UI → API calls
* [ ] UseCase used correctly
* [ ] Repository handles data
* [ ] Queue used for writes
* [ ] Clean separation of layers
* [ ] No unnecessary rebuilds
* [ ] Code is simple and readable

---

# 🧠 Final Note

> Keep things simple.
> Do not over-engineer.
> Follow the structure strictly.

If a solution feels complex, simplify it.

---

**This architecture is designed to scale with large teams and complex apps while remaining maintainable and performant.**
