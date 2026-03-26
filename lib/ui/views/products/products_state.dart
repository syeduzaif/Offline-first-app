import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_first_app/core/di/providers.dart';
import 'package:offline_first_app/data/repositories/categories_repository.dart';
import 'package:offline_first_app/data/repositories/products_repository.dart';
import 'package:offline_first_app/domain/models/category.dart';
import 'package:offline_first_app/domain/models/product.dart';

@immutable
class ProductsState {
  const ProductsState({
    this.products = const [],
    this.categories = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.isOnline = true,
    this.isSyncing = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentSkip = 0,
    this.totalProducts = 0,
    this.isRefreshing = false,
    this.isInitialLoading = true,
  });

  final List<Product> products;
  final List<ProductCategory> categories;
  final String? selectedCategory;
  final String searchQuery;
  final bool isOnline;
  final bool isSyncing;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentSkip;
  final int totalProducts;
  final bool isRefreshing;
  final bool isInitialLoading;

  ProductsState copyWith({
    List<Product>? products,
    List<ProductCategory>? categories,
    String? selectedCategory,
    String? searchQuery,
    bool? isOnline,
    bool? isSyncing,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentSkip,
    int? totalProducts,
    bool? isRefreshing,
    bool? isInitialLoading,
  }) {
    return ProductsState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isOnline: isOnline ?? this.isOnline,
      isSyncing: isSyncing ?? this.isSyncing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentSkip: currentSkip ?? this.currentSkip,
      totalProducts: totalProducts ?? this.totalProducts,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
    );
  }
}

final productsControllerProvider =
    NotifierProvider<ProductsController, ProductsState>(
  ProductsController.new,
);

class ProductsController extends Notifier<ProductsState> {
  late final ProductsRepository _productsRepo;
  late final CategoriesRepository _categoriesRepo;

  final ScrollController scrollController = ScrollController();

  StreamSubscription<List<Product>>? _productsSub;
  StreamSubscription<List<ProductCategory>>? _categoriesSub;
  Timer? _searchDebounce;

  static const int _pageSize = 20;

  @override
  ProductsState build() {
    _productsRepo = ref.read(productsRepositoryProvider);
    _categoriesRepo = ref.read(categoriesRepositoryProvider);
    final connectivity = ref.read(connectivityServiceProvider);
    final syncService = ref.read(syncServiceProvider);

    // Initialize state before any reads.
    state = ProductsState(
      isOnline: connectivity.isOnline,
      isSyncing: syncService.isSyncing,
    );

    ref.listen(connectivityStatusProvider, (previous, next) {
      state = state.copyWith(isOnline: next.value ?? true);
    });

    ref.listen(syncStatusProvider, (previous, next) {
      state = state.copyWith(isSyncing: next.value ?? false);
    });

    ref.onDispose(() {
      _searchDebounce?.cancel();
      _productsSub?.cancel();
      _categoriesSub?.cancel();
      scrollController.dispose();
    });

    _subscribeToProducts();
    _categoriesSub =
        _categoriesRepo.watchCategories().listen((cats) {
      state = state.copyWith(categories: cats);
    });
    scrollController.addListener(_onScroll);
    _initialFetch();

    return state;
  }

  Future<void> _initialFetch() async {
    try {
      final total = await _productsRepo.refreshProducts(
        limit: _pageSize,
        skip: 0,
      );
      state = state.copyWith(
        totalProducts: total,
        currentSkip: _pageSize,
        hasMore: _pageSize < total,
      );
      await _categoriesRepo.refreshCategories();
    } catch (_) {
      // Offline start — local DB serves cached data
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  void _subscribeToProducts() {
    _productsSub?.cancel();
    final query = state.searchQuery;
    final selectedCategory = state.selectedCategory;

    if (query.isNotEmpty) {
      _productsSub = _productsRepo
          .searchProducts(query)
          .listen(_onProductsChanged);
    } else if (selectedCategory != null) {
      _productsSub = _productsRepo
          .watchProductsByCategory(selectedCategory)
          .listen(_onProductsChanged);
    } else {
      _productsSub =
          _productsRepo.watchProducts().listen(_onProductsChanged);
    }
  }

  void _onProductsChanged(List<Product> products) {
    state = state.copyWith(
      products: products,
      isInitialLoading: false,
    );
  }

  void onSearchChanged(String query) {
    state = state.copyWith(searchQuery: query);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
      _subscribeToProducts,
    );
  }

  void selectCategory(String? slug) {
    state = state.copyWith(selectedCategory: slug);
    _subscribeToProducts();
  }

  Future<void> onRefresh() async {
    state = state.copyWith(isRefreshing: true, currentSkip: 0);
    try {
      final total = await _productsRepo.refreshProducts(
        limit: _pageSize,
        skip: 0,
      );
      state = state.copyWith(
        totalProducts: total,
        currentSkip: _pageSize,
        hasMore: _pageSize < total,
      );
      await _categoriesRepo.refreshCategories();
    } catch (_) {
      // Silently fail
    }
    state = state.copyWith(isRefreshing: false);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent -
                200 &&
        !state.isLoadingMore &&
        state.hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    state = state.copyWith(isLoadingMore: true);
    try {
      final total = await _productsRepo.refreshProducts(
        limit: _pageSize,
        skip: state.currentSkip,
      );
      final newSkip = state.currentSkip + _pageSize;
      state = state.copyWith(
        totalProducts: total,
        currentSkip: newSkip,
        hasMore: newSkip < total,
      );
    } catch (_) {}
    state = state.copyWith(isLoadingMore: false);
  }

  void navigateToDetail(BuildContext context, int id) {
    context.push('/product/$id');
  }

  void navigateToAddProduct(BuildContext context) {
    context.push('/product/add');
  }
}
