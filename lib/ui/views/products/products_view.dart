import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/core/providers/providers.dart';
import 'package:offline_first_app/ui/views/products/widgets/category_filter_chips_wdiget.dart';
import 'package:offline_first_app/ui/views/products/widgets/connectivity_banner_wdiget.dart';
import 'package:offline_first_app/ui/views/products/widgets/product_card_wdiget.dart';
import 'package:offline_first_app/ui/views/products/widgets/product_search_bar_wdiget.dart';
import 'package:offline_first_app/ui/widgets/empty_state_wdiget.dart';
import 'package:offline_first_app/ui/widgets/loading_indicator_wdiget.dart';

class ProductsView extends ConsumerStatefulWidget {
  const ProductsView({super.key});

  @override
  ConsumerState<ProductsView> createState() =>
      _ProductsViewState();
}

class _ProductsViewState extends ConsumerState<ProductsView> {
  final _scrollController = ScrollController();
  ProviderSubscription<String>? _searchQuerySub;
  ProviderSubscription<String?>? _selectedCategorySub;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  int _currentSkip = 0;
  int _totalProducts = 0;
  Timer? _searchDebounce;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchQuerySub = ref.listenManual<String>(
      productsSearchQueryProvider,
      (_, _) => _resetPagination(),
    );
    _selectedCategorySub = ref.listenManual<String?>(
      productsSelectedCategoryProvider,
      (_, _) => _resetPagination(),
    );
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _initialFetch());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchDebounce?.cancel();
    _searchQuerySub?.close();
    _selectedCategorySub?.close();
    super.dispose();
  }

  Future<void> _initialFetch() async {
    try {
      _totalProducts = await ref
          .read(productsRepositoryProvider)
          .refreshProducts(limit: _pageSize, skip: 0);
      if (mounted) {
        setState(() {
          _currentSkip = _pageSize;
          _hasMore = _currentSkip < _totalProducts;
        });
      }
      await ref
          .read(categoriesRepositoryProvider)
          .refreshCategories();
    } catch (_) {
      // Offline start — local DB serves cached data
    }
  }

  Future<void> _onRefresh() async {
    if (_isLoadingMore) return;
    setState(() {
      _currentSkip = 0;
      _hasMore = true;
    });
    try {
      _totalProducts = await ref
          .read(productsRepositoryProvider)
          .refreshProducts(limit: _pageSize, skip: 0);
      if (mounted) {
        setState(() {
          _currentSkip = _pageSize;
          _hasMore = _currentSkip < _totalProducts;
        });
      }
      await ref
          .read(categoriesRepositoryProvider)
          .refreshCategories();
    } catch (_) {
      // Roll back cursor so pagination stays consistent
      if (mounted) setState(() { _currentSkip = 0; _hasMore = true; });
    }
  }

  void _resetPagination() {
    if (!mounted) return;
    setState(() {
      _currentSkip = 0;
      _totalProducts = 0;
      _hasMore = false;
      _isLoadingMore = false;
    });
  }

  void _onScroll() {
    // Pagination only applies to the unfiltered view — local DB handles search/category
    final hasFilter = ref.read(productsSearchQueryProvider).isNotEmpty ||
        ref.read(productsSelectedCategoryProvider) != null;
    if (hasFilter) return;

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (mounted) setState(() => _isLoadingMore = true);
    try {
      _totalProducts = await ref
          .read(productsRepositoryProvider)
          .refreshProducts(limit: _pageSize, skip: _currentSkip);
      if (mounted) {
        setState(() {
          _currentSkip += _pageSize;
          _hasMore = _currentSkip < _totalProducts;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(CommonStrings.labelError)),
        );
      }
    }
    if (mounted) setState(() => _isLoadingMore = false);
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
      () => ref
          .read(productsSearchQueryProvider.notifier)
          .setQuery(query),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final isSyncing = ref.watch(isSyncingProvider);
    final selectedCategory =
        ref.watch(productsSelectedCategoryProvider);

    final products = productsAsync.valueOrNull ?? [];
    final categories = categoriesAsync.valueOrNull ?? [];
    final isLoading = productsAsync.isLoading;

    return Scaffold(
      backgroundColor: AppColors.primaryLighter,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connectivity banner
            ConnectivityBanner(isOnline: isOnline),
            // Header
            Padding(
              padding: EdgeInsets.only(
                left: AppPaddings.base,
                right: AppPaddings.base,
                top: AppPaddings.verticalMedium,
                bottom: AppPaddings.verticalBase,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ProductStrings.titleProducts,
                      style: AppTextStyles.h3.bold,
                    ),
                  ),
                  if (isSyncing)
                    SizedBox(
                      width: AppLayout.iconSizeMdSm,
                      height: AppLayout.iconSizeMdSm,
                      child:
                          const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
            // Search bar
            ProductSearchBar(onChanged: _onSearchChanged),
            SizedBox(height: AppLayout.height12),
            // Category chips
            CategoryFilterChips(
              categories: categories,
              selectedSlug: selectedCategory,
              onSelected: (slug) => ref
                  .read(
                      productsSelectedCategoryProvider.notifier)
                  .setCategory(slug),
            ),
            SizedBox(height: AppLayout.height12),
            // Product list
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppColors.primary,
                child: productsAsync.hasError
                    ? ListView(
                        children: [
                          SizedBox(
                              height: AppLayout.height140),
                          EmptyState(
                            message: CommonStrings.labelError,
                            icon: Iconsax.warning_2,
                          ),
                        ],
                      )
                    : products.isEmpty && !isLoading
                    ? ListView(
                        children: [
                          SizedBox(
                              height: AppLayout.height140),
                          EmptyState(
                            message: ProductStrings.noProducts,
                            icon: Iconsax.box_1,
                          ),
                        ],
                      )
                    : products.isEmpty
                        ? const LoadingIndicator()
                        : ListView.builder(
                            controller: _scrollController,
                            padding: AppPaddings.only(
                              left: AppPaddings.base,
                              right: AppPaddings.base,
                              bottom:
                                  AppLayout.bottomNavBarHeight +
                                      AppPaddings.base +
                                      AppPaddings.large,
                            ),
                            itemCount: products.length +
                                (_hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= products.length) {
                                return const LoadingIndicator();
                              }
                              final product = products[index];
                              return ProductCard(
                                key: ValueKey(product.id),
                                product: product,
                                onTap: () => context.push(
                                  '/product-detail',
                                  extra: product.id,
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: AppLayout.bottomNavBarHeight,
        ),
        child: FloatingActionButton(
          onPressed: () => context.push('/add-product'),
          backgroundColor: AppColors.primary,
          child: Icon(
            Iconsax.add,
            color: AppColors.white,
            size: AppLayout.iconSizeMd,
          ),
        ),
      ),
    );
  }
}
