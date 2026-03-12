import 'dart:async';

import 'package:flutter/material.dart';
import 'package:offline_first_app/app/app.locator.dart';
import 'package:offline_first_app/app/app.router.dart';
import 'package:offline_first_app/data/repositories/categories_repository.dart';
import 'package:offline_first_app/data/repositories/products_repository.dart';
import 'package:offline_first_app/domain/models/category.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/services/connectivity_service.dart';
import 'package:offline_first_app/services/sync_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ProductsViewModel extends ReactiveViewModel {
  final _productsRepo = locator<ProductsRepository>();
  final _categoriesRepo = locator<CategoriesRepository>();
  final _connectivityService = locator<ConnectivityService>();
  final _navigationService = locator<NavigationService>();
  final _syncService = locator<SyncService>();

  List<Product> _products = [];
  List<Product> get products => _products;

  List<ProductCategory> _categories = [];
  List<ProductCategory> get categories => _categories;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool get isOnline => _connectivityService.isOnline;
  bool get isSyncing => _syncService.isSyncing;

  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  int _currentSkip = 0;
  int _totalProducts = 0;
  static const int _pageSize = 20;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  final ScrollController scrollController = ScrollController();

  StreamSubscription<List<Product>>? _productsSub;
  StreamSubscription<List<ProductCategory>>? _categoriesSub;

  void initialize() {
    _subscribeToProducts();
    _categoriesSub =
        _categoriesRepo.watchCategories().listen((cats) {
      _categories = cats;
      notifyListeners();
    });
    scrollController.addListener(_onScroll);
    _initialFetch();
  }

  Future<void> _initialFetch() async {
    try {
      _totalProducts = await _productsRepo.refreshProducts(
        limit: _pageSize,
        skip: 0,
      );
      _currentSkip = _pageSize;
      _hasMore = _currentSkip < _totalProducts;
      await _categoriesRepo.refreshCategories();
    } catch (_) {
      // Offline start — local DB serves cached data
    }
  }

  void _subscribeToProducts() {
    _productsSub?.cancel();
    if (_searchQuery.isNotEmpty) {
      _productsSub = _productsRepo
          .searchProducts(_searchQuery)
          .listen(_onProductsChanged);
    } else if (_selectedCategory != null) {
      _productsSub = _productsRepo
          .watchProductsByCategory(_selectedCategory!)
          .listen(_onProductsChanged);
    } else {
      _productsSub = _productsRepo
          .watchProducts()
          .listen(_onProductsChanged);
    }
  }

  void _onProductsChanged(List<Product> products) {
    _products = products;
    notifyListeners();
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    _subscribeToProducts();
  }

  void selectCategory(String? slug) {
    _selectedCategory = slug;
    _subscribeToProducts();
    notifyListeners();
  }

  Future<void> onRefresh() async {
    _isRefreshing = true;
    notifyListeners();
    _currentSkip = 0;
    try {
      _totalProducts = await _productsRepo.refreshProducts(
        limit: _pageSize,
        skip: 0,
      );
      _currentSkip = _pageSize;
      _hasMore = _currentSkip < _totalProducts;
      await _categoriesRepo.refreshCategories();
    } catch (_) {
      // Silently fail
    }
    _isRefreshing = false;
    notifyListeners();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent -
                200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    _isLoadingMore = true;
    try {
      _totalProducts = await _productsRepo.refreshProducts(
        limit: _pageSize,
        skip: _currentSkip,
      );
      _currentSkip += _pageSize;
      _hasMore = _currentSkip < _totalProducts;
    } catch (_) {}
    _isLoadingMore = false;
  }

  void navigateToDetail(int id) {
    _navigationService.navigateTo(
      Routes.productDetailView,
      arguments: ProductDetailViewArguments(productId: id),
    );
  }

  void navigateToAddProduct() {
    _navigationService.navigateTo(Routes.addProductView);
  }

  @override
  List<ListenableServiceMixin> get listenableServices =>
      [_connectivityService, _syncService];

  @override
  void dispose() {
    _productsSub?.cancel();
    _categoriesSub?.cancel();
    scrollController.dispose();
    super.dispose();
  }
}
