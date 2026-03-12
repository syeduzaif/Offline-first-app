import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/ui/views/products/products_viewmodel.dart';
import 'package:offline_first_app/ui/views/products/widgets/category_filter_chips_wdiget.dart';
import 'package:offline_first_app/ui/views/products/widgets/connectivity_banner_wdiget.dart';
import 'package:offline_first_app/ui/views/products/widgets/product_card_wdiget.dart';
import 'package:offline_first_app/ui/views/products/widgets/product_search_bar_wdiget.dart';
import 'package:offline_first_app/ui/widgets/empty_state_wdiget.dart';
import 'package:offline_first_app/ui/widgets/loading_indicator_wdiget.dart';
import 'package:stacked/stacked.dart';

class ProductsView extends StackedView<ProductsViewModel> {
  const ProductsView({super.key});

  @override
  void onViewModelReady(ProductsViewModel viewModel) {
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    ProductsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.primaryLighter,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connectivity banner
            ConnectivityBanner(
                isOnline: viewModel.isOnline),
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
                  if (viewModel.isSyncing)
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
            ProductSearchBar(
                onChanged: viewModel.onSearchChanged),
            SizedBox(height: AppLayout.height12),
            // Category chips
            CategoryFilterChips(
              categories: viewModel.categories,
              selectedSlug: viewModel.selectedCategory,
              onSelected: viewModel.selectCategory,
            ),
            SizedBox(height: AppLayout.height12),
            // Product list
            Expanded(
              child: RefreshIndicator(
                onRefresh: viewModel.onRefresh,
                color: AppColors.primary,
                child: viewModel.products.isEmpty &&
                        !viewModel.isBusy
                    ? ListView(
                        children: [
                          SizedBox(
                              height:
                                  AppLayout.height140),
                          EmptyState(
                            message:
                                ProductStrings.noProducts,
                            icon: Iconsax.box_1,
                          ),
                        ],
                      )
                    : viewModel.products.isEmpty
                        ? const LoadingIndicator()
                        : ListView.builder(
                            controller: viewModel
                                .scrollController,
                            padding: AppPaddings.only(
                              left: AppPaddings.base,
                              right: AppPaddings.base,
                              bottom: AppLayout
                                      .bottomNavBarHeight +
                                  AppPaddings.base +
                                  AppPaddings.large,
                            ),
                            itemCount: viewModel
                                    .products.length +
                                (viewModel.hasMore
                                    ? 1
                                    : 0),
                            itemBuilder:
                                (context, index) {
                              if (index >=
                                  viewModel
                                      .products.length) {
                                return const LoadingIndicator();
                              }
                              final product = viewModel
                                  .products[index];
                              return ProductCard(
                                key: ValueKey(
                                    product.id),
                                product: product,
                                onTap: () => viewModel
                                    .navigateToDetail(
                                        product.id),
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
          onPressed: viewModel.navigateToAddProduct,
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

  @override
  ProductsViewModel viewModelBuilder(BuildContext context) =>
      ProductsViewModel();
}
