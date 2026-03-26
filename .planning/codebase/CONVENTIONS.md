# Code Conventions

## File Naming
- Widget files use `_wdiget.dart` suffix (note: intentional typo convention — NOT `_widget.dart`)
- Interface files prefixed with `i_`: e.g., `i_products_repository.dart`
- ViewModels suffixed `_view_model.dart`
- DTOs suffixed `_dto.dart`
- DAOs suffixed `_dao.dart`

## Class Patterns
- Non-instantiable constant classes use private constructor: `ClassName._()` (e.g., `AppColors`, `AppTextStyles`, `AppLayout`)
- Private fields prefixed `_` with public getters that expose them without the prefix
- Domain models and DTOs annotated with `@freezed` (code generation via `freezed` package)
- Interface abstraction pattern: abstract class `I_XRepository` implemented by concrete class

## ViewModel Hierarchy
- Base class: `AppViewModel` (extends ReactiveViewModel from stacked)
- Product listing: `ProductsViewModel extends ReactiveViewModel`
- Product creation: `AddProductViewModel extends AppViewModel`
- `TextStyleExtension` provides fluent helpers: `.bold`, `.withColor()` on `AppTextStyles`

## Error Handling
- Offline/sync paths: silent `catch (_)` — errors swallowed intentionally
- User-facing errors: surfaced via `SnackbarService`
- No structured error types — raw exceptions caught inline

## Styling
- Color constants in `AppColors` (non-instantiable)
- Text styles in `AppTextStyles` with fluent extension methods
- Layout constants in `AppLayout`
- No custom lint rules — uses `flutter_lints` defaults (`analysis_options.yaml`)

## Import Organization
- No enforced import ordering rules observed
- Relative imports used within feature directories

## Code Generation
- `@freezed` for immutable data classes (models, DTOs)
- `@DriftDatabase` / `@DataClassName` for Drift ORM
- `@Injectable` / `@lazySingleton` for GetIt dependency injection
- Run: `flutter pub run build_runner build`
