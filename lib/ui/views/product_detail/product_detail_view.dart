import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/ui/views/product_detail/product_detail_state.dart';
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
    final state = ref.watch(productDetailControllerProvider(productId));
    final controller =
        ref.read(productDetailControllerProvider(productId).notifier);

    final product = state.product;
    if (product == null) {
      return const Scaffold(
        body: LoadingIndicator(),
      );
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
            onPressed: () =>
                context.push('/product/${product.id}/edit'),
          ),
          IconButton(
            icon: Icon(
              Iconsax.trash,
              size: AppLayout.iconSizeMd,
              color: AppColors.failedText,
            ),
            onPressed: () => _confirmDelete(context, controller),
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

  Future<void> _confirmDelete(
    BuildContext context,
    ProductDetailController controller,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(ProductStrings.deleteProduct),
        content: const Text(ProductStrings.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(CommonStrings.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(CommonStrings.actionDelete),
          ),
        ],
      ),
    );
    if (result != true) return;

    try {
      await controller.deleteProduct();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ProductStrings.deleteSuccess)),
      );
      context.pop();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ProductStrings.errorDeleteFailed)),
      );
    }
  }
}
