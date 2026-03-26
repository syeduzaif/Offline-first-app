# Riverpod Migration Architecture (Stacked → Riverpod)

## Goals
- Replace Stacked with Riverpod (latest stable)
- Keep code simple, clean, maintainable
- Avoid over-engineering
- Production-ready best practices
- Offline-first friendly (optional)

## 1) Architecture Style
**Feature-first with thin layers inside each feature.**

- UI: screens and widgets only
- State: Riverpod providers/controllers
- Business logic: controllers + repositories (no heavy usecases unless needed)
- Data: repositories + data sources (remote/local)

## 2) Project Structure

```
lib/
  core/
    config/
      env.dart
    di/
      providers.dart
    network/
      api_client.dart
      interceptors.dart
      network_exceptions.dart
    local/
      database.dart
    logging/
      logger.dart
    utils/
      result.dart
      connectivity.dart
  features/
    auth/
      ui/
        login_screen.dart
        widgets/
      state/
        login_controller.dart
        login_state.dart
      data/
        auth_repository.dart
        auth_remote_ds.dart
        auth_local_ds.dart
        auth_models.dart
    home/
      ui/
      state/
      data/
  shared/
    ui/
      empty_state.dart
      loading_view.dart
      error_view.dart
    theme/
    extensions/
  main.dart
```

**Rules**
- Create a feature folder when it owns a screen/flow and data.
- Keep providers next to the feature UI.
- Repositories live inside `features/<feature>/data/`.

## 3) Riverpod Setup Rules
**Packages**
- `flutter_riverpod` for UI integration
- `riverpod` for pure Dart providers
- `hooks_riverpod` only if you already use Flutter Hooks (optional)

**Provider selection rules**
- `Provider`: stateless dependency (api client, repo, config)
- `NotifierProvider`: sync mutable UI state
- `AsyncNotifierProvider`: async load/save state (most cases)
- `StateNotifierProvider`: only for complex custom reducers or large legacy migrations

## 4) Migration Strategy
**Incremental feature migration**
1. Add Riverpod dependencies.
2. Migrate one feature at a time.
3. Convert ViewModel to Notifier/AsyncNotifier.
4. Replace `ViewModelBuilder` with `ConsumerWidget`/`Consumer`.
5. Remove Stacked bindings for that feature.
6. Repeat per feature.

**Stacked → Riverpod mapping**
- `BaseViewModel` async load → `AsyncNotifier`
- `BaseViewModel` simple state → `Notifier`

**Before (Stacked)**
```dart
class LoginViewModel extends BaseViewModel {
  String email = '';
  Future<void> login() async {
    setBusy(true);
    await _authService.login(email);
    setBusy(false);
  }
}
```

**After (Riverpod AsyncNotifier)**
```dart
final loginControllerProvider =
    AsyncNotifierProvider<LoginController, void>(LoginController.new);

class LoginController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> login(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).login(email);
    });
  }
}
```

**UI before**
```dart
ViewModelBuilder<LoginViewModel>.reactive(
  viewModelBuilder: () => LoginViewModel(),
  builder: (context, model, child) => ...
)
```

**UI after**
```dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginControllerProvider);
    return state.when(
      data: (_) => ...,
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(message: e.toString()),
    );
  }
}
```

## 5) Boilerplate Templates
**Feature layout**
```
features/<feature>/
  ui/<feature>_screen.dart
  state/<feature>_controller.dart
  state/<feature>_state.dart
  data/<feature>_repository.dart
  data/<feature>_remote_ds.dart
  data/<feature>_local_ds.dart
  data/<feature>_models.dart
```

**Sync state provider**
```dart
final counterProvider =
    NotifierProvider<CounterController, int>(CounterController.new);

class CounterController extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
}
```

**Async provider**
```dart
final itemsProvider =
    AsyncNotifierProvider<ItemsController, List<Item>>(ItemsController.new);

class ItemsController extends AsyncNotifier<List<Item>> {
  @override
  Future<List<Item>> build() {
    return ref.read(itemsRepositoryProvider).fetchItems();
  }
}
```

**Repository**
```dart
final itemsRepositoryProvider = Provider<ItemsRepository>((ref) {
  return ItemsRepository(
    remote: ref.read(itemsRemoteProvider),
    local: ref.read(itemsLocalProvider),
  );
});

class ItemsRepository {
  ItemsRepository({required this.remote, required this.local});
  final ItemsRemoteDataSource remote;
  final ItemsLocalDataSource local;

  Future<List<Item>> fetchItems() async {
    final cached = await local.getItems();
    if (cached.isNotEmpty) return cached;
    final fresh = await remote.getItems();
    await local.saveItems(fresh);
    return fresh;
  }
}
```

## 6) Navigation
**Recommended: go_router**
- Declarative, stable, production-friendly

**Setup**
```dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
    ],
    redirect: (context, state) {
      final isLoggedIn = ref.read(authRepositoryProvider).isLoggedIn;
      if (!isLoggedIn && state.matchedLocation != '/login') return '/login';
      return null;
    },
  );
});
```

## 7) Essential Packages
- State: `flutter_riverpod`, `riverpod`
- Networking: `dio`
- Local storage (offline-first): `drift`
- Logging: `logger`

## 8) Data Flow
UI → Provider → Repository → DataSource → API/DB

Rules:
- UI never calls API/DB directly.
- Providers never use Dio directly.
- Repository is the single source of truth.

## 9) Error Handling & Loading States
Use `AsyncValue` everywhere.

```dart
final state = ref.watch(itemsProvider);

return state.when(
  data: (items) => items.isEmpty
      ? const EmptyState()
      : ItemsList(items),
  loading: () => const LoadingView(),
  error: (e, _) => ErrorView(message: e.toString()),
);
```

## 10) Best Practices
**Do**
- Keep providers close to their feature.
- Use `ref.watch` in UI, `ref.read` in actions.
- Keep state small and focused.

**Don’t**
- Don’t make everything a `StateNotifier`.
- Don’t keep a massive global providers file.
- Don’t add service layers without a clear need.

## 11) Code Generation (Optional)
Use only if you want less boilerplate.
- `riverpod_generator`
- `riverpod_annotation`

Skip if your team prefers explicit code.

## 12) Offline-first (Simple Strategy)
- Drift as local source of truth.
- Repository reads from DB first, writes to DB after API.
- Sync: mark unsynced rows, upload in background, clear flags on success.

---

If you want, I can now produce a feature-by-feature migration plan tailored to this repo.
