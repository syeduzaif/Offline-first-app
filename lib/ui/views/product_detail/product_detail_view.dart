import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/ui/views/product_detail/product_detail_viewmodel.dart';
import 'package:offline_first_app/ui/views/product_detail/widgets/product_image_gallery_wdiget.dart';
import 'package:offline_first_app/ui/views/product_detail/widgets/product_info_section_wdiget.dart';
import 'package:offline_first_app/ui/widgets/loading_indicator_wdiget.dart';
import 'package:stacked/stacked.dart';

class ProductDetailView
    extends StackedView<ProductDetailViewModel> {
  const ProductDetailView({
    super.key,
    required this.productId,
  });

  final int productId;

  @override
  void onViewModelReady(ProductDetailViewModel viewModel) {
    viewModel.initialize(productId);
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    ProductDetailViewModel viewModel,
    Widget? child,
  ) {
    final product = viewModel.product;
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
            onPressed: viewModel.navigateToEdit,
          ),
          IconButton(
            icon: Icon(
              Iconsax.trash,
              size: AppLayout.iconSizeMd,
              color: AppColors.failedText,
            ),
            onPressed: viewModel.deleteProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image gallery
            Container(
              color: AppColors.primaryLighter,
              child: ProductImageGallery(
                images: product.images,
                thumbnail: product.thumbnail,
              ),
            ),
            // Info section
            ProductInfoSection(product: product),
          ],
        ),
      ),
    );
  }

  @override
  ProductDetailViewModel viewModelBuilder(
          BuildContext context) =>
      ProductDetailViewModel();
}
