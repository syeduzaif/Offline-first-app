import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/ui/views/product_detail/product_detail_controller.dart';
import 'package:offline_first_app/ui/views/product_detail/widgets/product_image_gallery_wdiget.dart';
import 'package:offline_first_app/ui/views/product_detail/widgets/product_info_section_wdiget.dart';
import 'package:offline_first_app/ui/widgets/loading_indicator_wdiget.dart';

class ProductDetailView extends ConsumerWidget {
  const ProductDetailView({
    super.key,
    required this.productId,
  });

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productProvider(productId));
    final controller =
        ref.read(productDetailControllerProvider.notifier);

    return productAsync.when(
      loading: () =>
          const Scaffold(body: LoadingIndicator()),
      error: (e, _) => Scaffold(
        body: Center(child: Text(e.toString())),
      ),
      data: (product) {
        if (product == null) {
          return const Scaffold(body: LoadingIndicator());
        }
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            title: Text(product.title),
            actions: [
              IconButton(
                icon: Icon(
                  Iconsax.edit,
                  size: AppLayout.iconSizeMd,
                ),
                onPressed: () => context.push(
                  '/product-edit',
                  extra: product,
                ),
              ),
              IconButton(
                icon: Icon(
                  Iconsax.trash,
                  size: AppLayout.iconSizeMd,
                  color: AppColors.failedText,
                ),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text(
                          ProductStrings.deleteProduct),
                      content: const Text(
                          ProductStrings.confirmDelete),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(
                              dialogContext, false),
                          child: const Text(
                              CommonStrings.actionCancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(
                              dialogContext, true),
                          child: const Text(
                              CommonStrings.actionDelete),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    final success = await controller
                        .deleteProduct(productId);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                              ProductStrings.deleteSuccess),
                        ),
                      );
                      context.pop();
                    }
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: AppColors.primaryLighter,
                  child: ProductImageGallery(
                    images: product.images,
                    thumbnail: product.thumbnail,
                  ),
                ),
                ProductInfoSection(product: product),
              ],
            ),
          ),
        );
      },
    );
  }
}
