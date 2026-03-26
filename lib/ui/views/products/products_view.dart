import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/ui/views/products/products_state.dart';
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
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(productsControllerProvider.notifier).tryLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsControllerProvider);
    final controller =
        ref.read(productsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.primaryLighter,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connectivity banner
            ConnectivityBanner(isOnline: state.isOnline),
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
                  if (state.isSyncing)
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
            // Search bar
            ProductSearchBar(onChanged: controller.onSearchChanged),
            SizedBox(height: AppLayout.height12),
            // Category chips
            CategoryFilterChips(
              categories: state.categories,
              selectedSlug: state.selectedCategory,
              onSelected: controller.selectCategory,
            ),
            SizedBox(height: AppLayout.height12),
            // Product list
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.onRefresh,
                color: AppColors.primary,
                child: state.products.isEmpty &&
                        !state.isInitialLoading
                    ? ListView(
                        children: [
                          SizedBox(height: AppLayout.height140),
                          EmptyState(
                            message: ProductStrings.noProducts,
                            icon: Iconsax.box_1,
                          ),
                        ],
                      )
                    : state.products.isEmpty
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
                            itemCount: state.products.length +
                                (state.hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= state.products.length) {
                                return const LoadingIndicator();
                              }
                              final product = state.products[index];
                              return ProductCard(
                                key: ValueKey(product.id),
                                product: product,
                                onTap: () =>
                                    context.push('/product/${product.id}'),
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
          onPressed: () => context.push('/product/add'),
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
