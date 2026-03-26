# Directory Structure

## Entry Points
- `lib/main.dart` — app bootstrap, DI setup, runApp
- `lib/app/app.dart` — MaterialApp, router, theme configuration
- `lib/app/app.locator.dart` — GetIt service locator (generated)
- `lib/app/app.router.dart` — Stacked navigation routes (generated)

## Directory Tree

```
lib/
├── main.dart                          # Entry point
├── app/
│   ├── app.dart                       # App widget
│   ├── app.locator.dart               # Generated DI locator
│   └── app.router.dart                # Generated route table
│
├── core/
│   ├── constants/
│   │   ├── app_animations.dart
│   │   ├── app_assets.dart
│   │   ├── app_colors.dart
│   │   ├── app_font_sizes.dart
│   │   ├── app_layout.dart
│   │   ├── app_margins.dart
│   │   ├── app_paddings.dart
│   │   ├── app_text_styles.dart
│   │   └── strings/
│   │       ├── app_strings.dart
│   │       ├── common_strings.dart
│   │       ├── product_strings.dart
│   │       └── sync_strings.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── viewmodels/
│       └── app_viewmodel.dart         # Base ViewModel
│
├── domain/
│   ├── models/
│   │   ├── category.dart              # @freezed domain model
│   │   ├── product.dart               # @freezed domain model
│   │   ├── sync_operation.dart        # @freezed domain model
│   │   └── sync_status.dart
│   └── repositories/
│       ├── i_categories_repository.dart   # Abstract interface
│       └── i_products_repository.dart     # Abstract interface
│
├── data/
│   ├── local/
│   │   ├── database.dart              # Drift AppDatabase (forTesting constructor)
│   │   ├── database.g.dart            # Generated
│   │   ├── tables/
│   │   │   ├── categories_table.dart
│   │   │   ├── products_table.dart
│   │   │   └── sync_queue_table.dart
│   │   └── daos/
│   │       ├── categories_dao.dart
│   │       ├── products_dao.dart
│   │       └── sync_queue_dao.dart
│   ├── remote/
│   │   ├── api_client.dart            # Dio HTTP client
│   │   ├── api_constants.dart         # Base URLs, endpoints
│   │   └── dtos/
│   │       ├── category_dto.dart      # @freezed + @JsonSerializable
│   │       └── product_dto.dart       # @freezed + @JsonSerializable
│   └── repositories/
│       ├── categories_repository.dart # Implements i_categories_repository
│       └── products_repository.dart   # Implements i_products_repository
│
├── services/
│   ├── connectivity_service.dart      # Network status monitoring
│   ├── database_service.dart          # DB lifecycle management
│   └── sync_service.dart              # Offline queue sync orchestration
│
└── ui/
    ├── widgets/                       # Shared/reusable widgets
    │   ├── empty_state_wdiget.dart
    │   ├── error_retry_wdiget.dart
    │   ├── loading_indicator_wdiget.dart
    │   └── sync_badge_wdiget.dart
    └── views/                         # Feature screens (view + viewmodel + widgets/)
        ├── main/                      # Shell: bottom nav + page routing
        ├── products/                  # Product listing with search/filter
        ├── product_detail/            # Product detail with image gallery
        ├── add_product/               # Create product form
        ├── edit_product/              # Edit product form
        └── sync_queue/                # Pending sync operations viewer
```

## Naming Conventions
- Views: `{feature}_view.dart`
- ViewModels: `{feature}_viewmodel.dart`
- Widget files: `{name}_wdiget.dart` (note: `wdiget` typo is the established project convention)
- Interfaces: `i_{name}_repository.dart`
- Generated files: `*.g.dart`, `*.freezed.dart`

## Feature Organization
Each view directory contains:
- `{feature}_view.dart` — UI widget
- `{feature}_viewmodel.dart` — state + business logic
- `widgets/` — view-local widgets (not shared)

## Where to Place New Code
- New domain model → `lib/domain/models/`
- New repository interface → `lib/domain/repositories/`
- New repository impl → `lib/data/repositories/`
- New DB table → `lib/data/local/tables/` + DAO in `lib/data/local/daos/`
- New remote DTO → `lib/data/remote/dtos/`
- New service → `lib/services/`
- New screen → `lib/ui/views/{feature}/` with view + viewmodel + `widgets/`
- Shared widget → `lib/ui/widgets/`
- New constant → `lib/core/constants/`
