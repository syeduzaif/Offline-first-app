# Testing

## Framework
- `flutter_test` (Flutter SDK built-in) — no additional test packages
- No `mockito`, `mocktail`, `bloc_test`, or integration test packages in dependencies

## Test Coverage
- **Effectively 0%** business logic coverage
- Only file: `test/widget_test.dart` — auto-generated Flutter scaffold test
- The scaffold test is **stale/broken**: tests a default counter app, not the actual product catalog app (references `MyApp()` counter that doesn't exist in this codebase)

## Test Infrastructure
- `AppDatabase.forTesting(super.e)` constructor exists in `lib/data/local/database.dart` — indicates intent for in-memory DB testing, but no tests currently use it
- No mock repositories or service stubs exist

## What's Missing
- Unit tests for ViewModels (`ProductsViewModel`, `AddProductViewModel`)
- Unit tests for repositories (`ProductsRepository`)
- DAO tests using the `forTesting` constructor
- Widget tests for screens and components
- Integration tests for sync flows

## CI/CD
- No CI configuration detected (no `.github/workflows/`, `.gitlab-ci.yml`, `Fastfile`, etc.)

## Notes
- The `forTesting` DB constructor is the main test-readiness signal — it was built with testability in mind but never exercised
- Adding tests would require adding `mockito` or `mocktail` to dev dependencies for mocking `IProductsRepository` and services
