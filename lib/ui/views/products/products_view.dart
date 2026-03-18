import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/providers/service_providers.dart';
import 'package:offline_first_app/ui/views/products/products_controller.dart';
import 'package:offline_first_app/ui/views/products/widgets/category_filter_chips_wdiget.dart';
import 'package:offline_first_app/ui/views/products/widgets/connectivity_banner_wdiget.dart';
import 'package:offline_first_app/ui/views/products/widgets/product_card_wdiget.dart';
import 'package:offline_first_app/ui/views/products/widgets/product_search_bar_wdiget.dart';
import 'package:offline_first_app/ui/widgets/empty_state_wdiget.dart';
import 'package:offline_first_app/ui/widgets/loading_indicator_wdiget.dart';

class ProductsView extends HookConsumerWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productsControllerProvider);
    final controller =
        ref.read(productsControllerProvider.notifier);
    final isOnline =
        ref.watch(isOnlineProvider).valueOrNull ?? true;
    final isSyncing =
        ref.watch(isSyncingProvider).valueOrNull ?? false;

    final scrollController = useScrollController();

    // Trigger pagination when near the bottom of the list
    useEffect(() {
      void onScroll() {
        if (scrollController.hasClients &&
            scrollController.position.pixels >=
                scrollController.position.maxScrollExtent -
                    200) {
          controller.loadMore();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

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
                      child:
                          const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
            ProductSearchBar(
                onChanged: controller.onSearchChanged),
            SizedBox(height: AppLayout.height12),
            CategoryFilterChips(
              categories: state.categories,
              selectedSlug: state.selectedCategory,
              onSelected: controller.selectCategory,
            ),
            SizedBox(height: AppLayout.height12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.onRefresh,
                color: AppColors.primary,
                child:
                    state.products.isEmpty && !state.isRefreshing
                        ? ListView(
                            children: [
                              SizedBox(
                                  height: AppLayout.height140),
                              EmptyState(
                                message:
                                    ProductStrings.noProducts,
                                icon: Iconsax.box_1,
                              ),
                            ],
                          )
                        : state.products.isEmpty
                            ? const LoadingIndicator()
                            : ListView.builder(
                                controller: scrollController,
                                padding: AppPaddings.only(
                                  left: AppPaddings.base,
                                  right: AppPaddings.base,
                                  bottom: AppLayout
                                          .bottomNavBarHeight +
                                      AppPaddings.base +
                                      AppPaddings.large,
                                ),
                                itemCount:
                                    state.products.length +
                                        (state.hasMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >=
                                      state.products.length) {
                                    return const LoadingIndicator();
                                  }
                                  final product =
                                      state.products[index];
                                  return ProductCard(
                                    key: ValueKey(product.id),
                                    product: product,
                                    onTap: () => context.push(
                                      '/product-detail/${product.id}',
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
            bottom: AppLayout.bottomNavBarHeight),
        child: FloatingActionButton(
          onPressed: () => context.push('/product-add'),
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
