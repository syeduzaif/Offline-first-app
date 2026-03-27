import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/core/providers/providers.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/ui/views/product_detail/widgets/product_image_gallery_wdiget.dart';
import 'package:offline_first_app/ui/views/product_detail/widgets/product_info_section_wdiget.dart';
import 'package:offline_first_app/ui/widgets/error_retry_wdiget.dart';
import 'package:offline_first_app/ui/widgets/loading_indicator_wdiget.dart';

class ProductDetailView extends ConsumerWidget {
  const ProductDetailView({
    super.key,
    required this.productId,
  });

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync =
        ref.watch(productDetailProvider(productId));

    return productAsync.when(
      loading: () => const Scaffold(body: LoadingIndicator()),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorRetry(
          message: CommonStrings.labelError,
          onRetry: () => ref.invalidate(productDetailProvider(productId)),
        ),
      ),
      data: (product) {
        if (product == null) {
          return Scaffold(
            appBar: AppBar(),
            body: ErrorRetry(
              message: ProductStrings.noProducts,
              onRetry: () => ref.invalidate(
                productDetailProvider(productId),
              ),
            ),
          );
        }
        return _ProductDetailContent(product: product);
      },
    );
  }
}

class _ProductDetailContent extends ConsumerWidget {
  const _ProductDetailContent({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            onPressed: () =>
                context.push('/edit-product', extra: product),
          ),
          IconButton(
            icon: Icon(
              Iconsax.trash,
              size: AppLayout.iconSizeMd,
              color: AppColors.failedText,
            ),
            onPressed: () =>
                _showDeleteConfirmation(context, ref),
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
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(ProductStrings.deleteProduct),
        content: const Text(ProductStrings.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(CommonStrings.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(CommonStrings.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(productsRepositoryProvider)
        .deleteProduct(product.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(ProductStrings.deleteSuccess),
        ),
      );
      Navigator.of(context).pop();
    }
  }
}
