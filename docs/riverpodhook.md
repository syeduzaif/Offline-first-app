# 📘 Riverpod Hooks Guidelines for Flutter Offline-First App

## 🎯 Purpose

This document defines **strict rules and best practices** for using `flutter_hooks` and `hooks_riverpod` in your offline-first Flutter app. It ensures:

* Clean UI code
* Full compliance with Clean Architecture
* Separation of concerns
* High performance
* Minimal boilerplate

---

# 🧱 1. Core Principles

1. **Hooks are UI-layer only**
2. **Keep hooks simple and readable**
3. **Do not mix business logic inside hooks**
4. **Use hooks for lifecycle, state, and UI convenience**
5. **Controllers remain pure and do not use hooks**

---

# 🧭 2. Allowed Layer Usage

| Layer                  | Usage                                                       |
| ---------------------- | ----------------------------------------------------------- |
| `presentation/screens` | ✅ `HookConsumerWidget` for screen-level state and lifecycle |
| `presentation/widgets` | ✅ Optional for local widget state or animation              |
| `controllers`          | ❌ Not allowed                                               |
| `usecases`             | ❌ Not allowed                                               |
| `repositories`         | ❌ Not allowed                                               |

---

# 🎨 3. Recommended Hooks Usage

### Use Hooks For:

* `useState` → local UI state
* `useTextEditingController` → text field controllers
* `useScrollController` → scroll management
* `useAnimationController` → animations
* `useEffect` → lifecycle initialization and cleanup
* `useMemoized` → expensive computations
* `useStream` → subscribing to streams for UI only

---

# 🧩 4. Example: Screen with Hooks

```dart
class AttendanceScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(attendanceControllerProvider);

    // UI state
    final searchController = useTextEditingController();

    // Lifecycle hook
    useEffect(() {
      // perform initialization
      return null; // optional cleanup
    }, []);

    return Scaffold(
      appBar: AppBar(title: Text("Attendance")),
      body: Column(
        children: [
          TextField(controller: searchController),
          Expanded(
            child: ListView.builder(
              itemCount: controller.students.length,
              itemBuilder: (_, index) {
                return Text(controller.students[index].name);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

---

# ❌ 5. Hooks Anti-Patterns

Do **not**:

```dart
useEffect(() {
  ref.read(repository).fetchData(); // ❌ business logic in UI
}, []);
```

```dart
final students = useState(ref.watch(attendanceRepositoryProvider).getStudents()); // ❌ direct repo access
```

```dart
useEffect(() {
  controller.markAttendance(student); // ❌ Should call UseCase via controller
}, []);
```

---

# ⚡ 6. Performance Guidelines

* Use `ref.watch(provider.select(...))` to rebuild only necessary parts
* Use `useMemoized` for expensive computations
* Keep widget trees shallow, each widget should watch only its required state
* Avoid storing large objects in hook state (`useState`)

---

# 🧠 7. Team Rules

1. One controller per screen/feature
2. Hooks allowed **only in UI layer**
3. No repository or API access in hooks
4. Use hooks only for **temporary UI state or lifecycle**
5. Controllers handle all business logic

---

# 🔌 8. Optional Hook Utilities

* `useDebounce` → for search fields
* `useFormController` → for forms
* `useConnectivity` → wrapper for connectivity events
* `useAsyncEffect` → async initialization without polluting controller

---

# 🧪 9. Testing Guidelines

* Test hooks only for **UI behavior** (state changes, lifecycle)
* Do not include business logic tests in hooks
* Use `WidgetTester` with `HookWidget` or `HookConsumerWidget`

---

# ✅ 10. Final Checklist

* [ ] Hooks used **only in UI layer**
* [ ] No business logic in hooks
* [ ] Lifecycle, state, and animation only
* [ ] Controller handles all API/DB/UseCase
* [ ] Avoid storing large objects in hook state
* [ ] Use selective watching for performance

---

# 🏁 Final Note

> Hooks are a **UI convenience tool**, not a replacement for your architecture.
> Follow these rules strictly to maintain clean, scalable, and performant code.

---

**This guide complements your main Flutter offline-first architecture and is designed for team-wide adoption.**
