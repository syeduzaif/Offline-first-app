import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/domain/models/category.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/providers/core_providers.dart';

// ─── Filter state ───────────────────────────────────────────────────────────

class ProductsFilter {
  const ProductsFilter({
    this.searchQuery = '',
    this.selectedCategory,
  });

  final String searchQuery;
  final String? selectedCategory;

  ProductsFilter copyWith({
    String? searchQuery,
    Object? selectedCategory = _sentinel,
  }) {
    return ProductsFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory == _sentinel
          ? this.selectedCategory
          : selectedCategory as String?,
    );
  }
}

const _sentinel = Object();

class ProductsFilterController extends Notifier<ProductsFilter> {
  @override
  ProductsFilter build() => const ProductsFilter();

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectCategory(String? slug) {
    state = state.copyWith(selectedCategory: slug);
  }
}

final productsFilterProvider =
    NotifierProvider<ProductsFilterController, ProductsFilter>(
  ProductsFilterController.new,
);

// ─── Reactive data streams ───────────────────────────────────────────────────

/// Live product list from the local DB, reacts to filter changes.
final productsProvider = StreamProvider<List<Product>>((ref) {
  final filter = ref.watch(productsFilterProvider);
  final repo = ref.watch(productsRepositoryProvider);

  if (filter.searchQuery.isNotEmpty) {
    return repo.searchProducts(filter.searchQuery);
  }
  if (filter.selectedCategory != null) {
    return repo.watchProductsByCategory(filter.selectedCategory!);
  }
  return repo.watchProducts();
});

/// Live category list from the local DB.
final categoriesProvider =
    StreamProvider<List<ProductCategory>>((ref) {
  return ref.watch(categoriesRepositoryProvider).watchCategories();
});

// ─── Pagination state ────────────────────────────────────────────────────────

class ProductsPaginationState {
  const ProductsPaginationState({
    this.hasMore = true,
    this.currentSkip = 0,
    this.totalCount = 0,
    this.isLoadingMore = false,
  });

  final bool hasMore;
  final int currentSkip;
  final int totalCount;
  final bool isLoadingMore;

  ProductsPaginationState copyWith({
    bool? hasMore,
    int? currentSkip,
    int? totalCount,
    bool? isLoadingMore,
  }) {
    return ProductsPaginationState(
      hasMore: hasMore ?? this.hasMore,
      currentSkip: currentSkip ?? this.currentSkip,
      totalCount: totalCount ?? this.totalCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ProductsPaginationController
    extends Notifier<ProductsPaginationState> {
  static const int _pageSize = 20;

  @override
  ProductsPaginationState build() => const ProductsPaginationState();

  Future<void> initialFetch() async {
    try {
      final repo = ref.read(productsRepositoryProvider);
      final categoriesRepo = ref.read(categoriesRepositoryProvider);
      final total = await repo.refreshProducts(
        limit: _pageSize,
        skip: 0,
      );
      state = ProductsPaginationState(
        hasMore: _pageSize < total,
        currentSkip: _pageSize,
        totalCount: total,
      );
      await categoriesRepo.refreshCategories();
    } catch (_) {}
  }

  Future<void> refresh() async {
    try {
      final repo = ref.read(productsRepositoryProvider);
      final categoriesRepo = ref.read(categoriesRepositoryProvider);
      final total = await repo.refreshProducts(
        limit: _pageSize,
        skip: 0,
      );
      state = ProductsPaginationState(
        hasMore: _pageSize < total,
        currentSkip: _pageSize,
        totalCount: total,
      );
      await categoriesRepo.refreshCategories();
    } catch (_) {}
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final repo = ref.read(productsRepositoryProvider);
      final total = await repo.refreshProducts(
        limit: _pageSize,
        skip: state.currentSkip,
      );
      final newSkip = state.currentSkip + _pageSize;
      state = ProductsPaginationState(
        hasMore: newSkip < total,
        currentSkip: newSkip,
        totalCount: total,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final productsPaginationProvider = NotifierProvider<
    ProductsPaginationController, ProductsPaginationState>(
  ProductsPaginationController.new,
);
