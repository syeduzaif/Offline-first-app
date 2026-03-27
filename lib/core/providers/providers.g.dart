// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'5272999ed4821a8f4137b2c9bb5c7ad0e11321f6';

/// See also [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = Provider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = ProviderRef<AppDatabase>;
String _$apiClientHash() => r'479b0c82d498ad6e595b624f1b5f9d8308089164';

/// See also [apiClient].
@ProviderFor(apiClient)
final apiClientProvider = Provider<ApiClient>.internal(
  apiClient,
  name: r'apiClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$apiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ApiClientRef = ProviderRef<ApiClient>;
String _$productsRepositoryHash() =>
    r'8e7d7b4cfda0a342498a97292f6df0323946c532';

/// See also [productsRepository].
@ProviderFor(productsRepository)
final productsRepositoryProvider = Provider<ProductsRepository>.internal(
  productsRepository,
  name: r'productsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductsRepositoryRef = ProviderRef<ProductsRepository>;
String _$categoriesRepositoryHash() =>
    r'c1933f21bb4d03906cd7a4d30e0ef302104bab4d';

/// See also [categoriesRepository].
@ProviderFor(categoriesRepository)
final categoriesRepositoryProvider = Provider<CategoriesRepository>.internal(
  categoriesRepository,
  name: r'categoriesRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoriesRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoriesRepositoryRef = ProviderRef<CategoriesRepository>;
String _$isOnlineHash() => r'18bbbe62e70a015d072f1004b8e20771581b95cd';

/// See also [isOnline].
@ProviderFor(isOnline)
final isOnlineProvider = AutoDisposeProvider<bool>.internal(
  isOnline,
  name: r'isOnlineProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isOnlineHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsOnlineRef = AutoDisposeProviderRef<bool>;
String _$isSyncingHash() => r'973ab3add1261a95b9664d3e804169d90f004512';

/// See also [isSyncing].
@ProviderFor(isSyncing)
final isSyncingProvider = AutoDisposeProvider<bool>.internal(
  isSyncing,
  name: r'isSyncingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isSyncingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsSyncingRef = AutoDisposeProviderRef<bool>;
String _$pendingSyncCountHash() => r'a1b01655079824d94c65b623c0ea546ff331e8c0';

/// See also [pendingSyncCount].
@ProviderFor(pendingSyncCount)
final pendingSyncCountProvider = AutoDisposeStreamProvider<int>.internal(
  pendingSyncCount,
  name: r'pendingSyncCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingSyncCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingSyncCountRef = AutoDisposeStreamProviderRef<int>;
String _$productsStreamHash() => r'36e3dd8cb81805f5a55f2c0784c53bc76c7e8649';

/// See also [productsStream].
@ProviderFor(productsStream)
final productsStreamProvider =
    AutoDisposeStreamProvider<List<Product>>.internal(
      productsStream,
      name: r'productsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$productsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
typedef ProductsStreamRef = AutoDisposeStreamProviderRef<List<Product>>;
String _$categoriesStreamHash() => r'fb126d51d9e3c96c715799ceb4b873db96585240';

/// See also [categoriesStream].
@ProviderFor(categoriesStream)
final categoriesStreamProvider =
    AutoDisposeStreamProvider<List<ProductCategory>>.internal(
      categoriesStream,
      name: r'categoriesStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$categoriesStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoriesStreamRef =
    AutoDisposeStreamProviderRef<List<ProductCategory>>;
String _$productDetailHash() => r'226a5b2f13180bf55f32c9688173b21059952836';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [productDetail].
@ProviderFor(productDetail)
const productDetailProvider = ProductDetailFamily();

/// See also [productDetail].
class ProductDetailFamily extends Family<AsyncValue<Product?>> {
  /// See also [productDetail].
  const ProductDetailFamily();

  /// See also [productDetail].
  ProductDetailProvider call(int id) {
    return ProductDetailProvider(id);
  }

  @override
  ProductDetailProvider getProviderOverride(
    covariant ProductDetailProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'productDetailProvider';
}

/// See also [productDetail].
class ProductDetailProvider extends AutoDisposeStreamProvider<Product?> {
  /// See also [productDetail].
  ProductDetailProvider(int id)
    : this._internal(
        (ref) => productDetail(ref as ProductDetailRef, id),
        from: productDetailProvider,
        name: r'productDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$productDetailHash,
        dependencies: ProductDetailFamily._dependencies,
        allTransitiveDependencies:
            ProductDetailFamily._allTransitiveDependencies,
        id: id,
      );

  ProductDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    Stream<Product?> Function(ProductDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductDetailProvider._internal(
        (ref) => create(ref as ProductDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Product?> createElement() {
    return _ProductDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProductDetailRef on AutoDisposeStreamProviderRef<Product?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _ProductDetailProviderElement
    extends AutoDisposeStreamProviderElement<Product?>
    with ProductDetailRef {
  _ProductDetailProviderElement(super.provider);

  @override
  int get id => (origin as ProductDetailProvider).id;
}

String _$syncOperationsHash() => r'91b8d8cf8a4a4cd431afa61b72a8849553387332';

/// See also [syncOperations].
@ProviderFor(syncOperations)
final syncOperationsProvider =
    AutoDisposeStreamProvider<List<SyncOperation>>.internal(
      syncOperations,
      name: r'syncOperationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$syncOperationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncOperationsRef = AutoDisposeStreamProviderRef<List<SyncOperation>>;
String _$currentTabHash() => r'bf01317714d82079664ca41f103502a05da91d46';

/// See also [CurrentTab].
@ProviderFor(CurrentTab)
final currentTabProvider =
    AutoDisposeNotifierProvider<CurrentTab, int>.internal(
      CurrentTab.new,
      name: r'currentTabProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentTabHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentTab = AutoDisposeNotifier<int>;
String _$productsSearchQueryHash() =>
    r'15729603ecbf806322b58d9657ce8651bc6edea4';

/// See also [ProductsSearchQuery].
@ProviderFor(ProductsSearchQuery)
final productsSearchQueryProvider =
    AutoDisposeNotifierProvider<ProductsSearchQuery, String>.internal(
      ProductsSearchQuery.new,
      name: r'productsSearchQueryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$productsSearchQueryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProductsSearchQuery = AutoDisposeNotifier<String>;
String _$productsSelectedCategoryHash() =>
    r'ee12fdc8a423fe94b4d02f818c18be48077e1b46';

/// See also [ProductsSelectedCategory].
@ProviderFor(ProductsSelectedCategory)
final productsSelectedCategoryProvider =
    AutoDisposeNotifierProvider<ProductsSelectedCategory, String?>.internal(
      ProductsSelectedCategory.new,
      name: r'productsSelectedCategoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$productsSelectedCategoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProductsSelectedCategory = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
