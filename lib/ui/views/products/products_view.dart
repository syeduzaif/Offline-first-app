import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/providers/core_providers.dart';
import 'package:offline_first_app/ui/views/product_detail/product_detail_view.dart';
import 'package:offline_first_app/ui/views/add_product/add_product_view.dart';
import 'package:offline_first_app/ui/views/products/products_providers.dart';
import 'package:offline_first_app/ui/views/products/widgets/category_filter_chips_wdiget.dart';
import 'package:offline_first_app/ui/views/products/widgets/connectivity_banner_wdiget.dart';
import 'package:offline_first_app/ui/views/products/widgets/product_card_wdiget.dart';
import 'package:offline_first_app/ui/views/products/widgets/product_search_bar_wdiget.dart';
import 'package:offline_first_app/ui/widgets/empty_state_wdiget.dart';
import 'package:offline_first_app/ui/widgets/loading_indicator_wdiget.dart';

class ProductsView extends ConsumerStatefulWidget {
  const ProductsView({super.key});

  @override
  ConsumerState<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends ConsumerState<ProductsView> {
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsPaginationProvider.notifier).initialFetch();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !ref.read(productsPaginationProvider).isLoadingMore &&
        ref.read(productsPaginationProvider).hasMore) {
      ref.read(productsPaginationProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
      () => ref
          .read(productsFilterProvider.notifier)
          .setSearch(query),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products =
        ref.watch(productsProvider).valueOrNull ?? [];
    final categories =
        ref.watch(categoriesProvider).valueOrNull ?? [];
    final filter = ref.watch(productsFilterProvider);
    final pagination = ref.watch(productsPaginationProvider);
    final isOnline =
        ref.watch(connectivityStatusProvider).valueOrNull ?? true;
    final isSyncing =
        ref.watch(isSyncingProvider).valueOrNull ?? false;
    final isLoading = ref.watch(productsProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.primaryLighter,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConnectivityBanner(isOnline: isOnline),
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
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
            ProductSearchBar(onChanged: _onSearchChanged),
            SizedBox(height: AppLayout.height12),
            CategoryFilterChips(
              categories: categories,
              selectedSlug: filter.selectedCategory,
              onSelected: ref
                  .read(productsFilterProvider.notifier)
                  .selectCategory,
            ),
            SizedBox(height: AppLayout.height12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref
                    .read(productsPaginationProvider.notifier)
                    .refresh(),
                color: AppColors.primary,
                child: products.isEmpty && !isLoading
                    ? ListView(
                        children: [
                          SizedBox(height: AppLayout.height140),
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
                                (pagination.hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= products.length) {
                                return const LoadingIndicator();
                              }
                              final product = products[index];
                              return ProductCard(
                                key: ValueKey(product.id),
                                product: product,
                                onTap: () =>
                                    Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailView(
                                      productId: product.id,
                                    ),
                                  ),
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
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddProductView(),
            ),
          ),
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
