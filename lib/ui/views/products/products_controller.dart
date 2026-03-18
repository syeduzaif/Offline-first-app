import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:offline_first_app/domain/models/category.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/providers/service_providers.dart';

class ProductsState {
  final List<Product> products;
  final List<ProductCategory> categories;
  final String? selectedCategory;
  final String searchQuery;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasMore;

  const ProductsState({
    this.products = const [],
    this.categories = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  ProductsState copyWith({
    List<Product>? products,
    List<ProductCategory>? categories,
    String? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return ProductsState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategory:
          clearCategory ? null : selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ProductsController extends StateNotifier<ProductsState> {
  ProductsController(this._ref) : super(const ProductsState());

  final Ref _ref;

  StreamSubscription<List<Product>>? _productsSub;
  StreamSubscription<List<ProductCategory>>? _categoriesSub;

  int _currentSkip = 0;
  int _totalProducts = 0;
  static const int _pageSize = 20;

  void initialize() {
    _subscribeToProducts();
    _categoriesSub = _ref
        .read(categoriesRepositoryProvider)
        .watchCategories()
        .listen((cats) {
      state = state.copyWith(categories: cats);
    });
    _initialFetch();
  }

  Future<void> _initialFetch() async {
    try {
      _totalProducts = await _ref
          .read(productsRepositoryProvider)
          .refreshProducts(limit: _pageSize, skip: 0);
      _currentSkip = _pageSize;
      state = state.copyWith(hasMore: _currentSkip < _totalProducts);
      await _ref.read(categoriesRepositoryProvider).refreshCategories();
    } catch (_) {
      // Offline start — local DB serves cached data
    }
  }

  void _subscribeToProducts() {
    _productsSub?.cancel();
    final repo = _ref.read(productsRepositoryProvider);
    final Stream<List<Product>> stream;

    if (state.searchQuery.isNotEmpty) {
      stream = repo.searchProducts(state.searchQuery);
    } else if (state.selectedCategory != null) {
      stream =
          repo.watchProductsByCategory(state.selectedCategory!);
    } else {
      stream = repo.watchProducts();
    }

    _productsSub = stream.listen((products) {
      state = state.copyWith(products: products);
    });
  }

  void onSearchChanged(String query) {
    state = state.copyWith(searchQuery: query);
    _subscribeToProducts();
  }

  void selectCategory(String? slug) {
    if (slug == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: slug);
    }
    _subscribeToProducts();
  }

  Future<void> onRefresh() async {
    state = state.copyWith(isRefreshing: true);
    _currentSkip = 0;
    try {
      _totalProducts = await _ref
          .read(productsRepositoryProvider)
          .refreshProducts(limit: _pageSize, skip: 0);
      _currentSkip = _pageSize;
      state = state.copyWith(
        isRefreshing: false,
        hasMore: _currentSkip < _totalProducts,
      );
      await _ref.read(categoriesRepositoryProvider).refreshCategories();
    } catch (_) {
      state = state.copyWith(isRefreshing: false);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      _totalProducts = await _ref
          .read(productsRepositoryProvider)
          .refreshProducts(limit: _pageSize, skip: _currentSkip);
      _currentSkip += _pageSize;
      state = state.copyWith(
        isLoadingMore: false,
        hasMore: _currentSkip < _totalProducts,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  @override
  void dispose() {
    _productsSub?.cancel();
    _categoriesSub?.cancel();
    super.dispose();
  }
}

final productsControllerProvider =
    StateNotifierProvider<ProductsController, ProductsState>((ref) {
  final controller = ProductsController(ref);
  controller.initialize();
  return controller;
});
