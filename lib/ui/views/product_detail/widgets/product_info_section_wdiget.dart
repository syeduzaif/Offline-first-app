import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/ui/widgets/sync_badge_wdiget.dart';

class ProductInfoSection extends StatelessWidget {
  const ProductInfoSection({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPaddings.allBase,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + sync badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  product.title,
                  style: AppTextStyles.h4.bold,
                ),
              ),
              SizedBox(width: AppLayout.width8),
              SyncBadge(status: product.syncStatus),
            ],
          ),
          SizedBox(height: AppLayout.height4),
          // Brand
          if (product.brand.isNotEmpty)
            Text(
              product.brand,
              style: AppTextStyles.bodyMd
                  .withColor(AppColors.grayMedium),
            ),
          SizedBox(height: AppLayout.height12),
          // Price row
          Row(
            children: [
              Text(
                ProductStrings.priceLabel(product.price),
                style: AppTextStyles.h3.bold
                    .withColor(AppColors.primary),
              ),
              if (product.discountPercentage > 0) ...[
                SizedBox(width: AppLayout.width12),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppPaddings.small,
                    vertical: AppPaddings.verticalSmallest,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.failedBg,
                    borderRadius: BorderRadius.circular(
                        AppLayout.radiusSm),
                  ),
                  child: Text(
                    ProductStrings.discountLabel(
                        product.discountPercentage),
                    style: AppTextStyles.labelMd.bold
                        .withColor(AppColors.discountRed),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: AppLayout.height16),
          // Rating + stock row
          Row(
            children: [
              Icon(
                Iconsax.star1,
                size: AppLayout.iconSizeMdSm,
                color: AppColors.starYellow,
              ),
              SizedBox(width: AppLayout.width4),
              Text(
                ProductStrings.ratingLabel(product.rating),
                style: AppTextStyles.titleSm.semiBold,
              ),
              SizedBox(width: AppLayout.width24),
              Icon(
                Iconsax.box_1,
                size: AppLayout.iconSizeMdSm,
                color: product.stock > 0
                    ? AppColors.stockGreen
                    : AppColors.outOfStock,
              ),
              SizedBox(width: AppLayout.width4),
              Text(
                product.stock > 0
                    ? ProductStrings.stockCount(
                        product.stock)
                    : ProductStrings.outOfStock,
                style: AppTextStyles.bodyMd.semiBold
                    .withColor(
                  product.stock > 0
                      ? AppColors.stockGreen
                      : AppColors.outOfStock,
                ),
              ),
            ],
          ),
          SizedBox(height: AppLayout.height16),
          // Category chip
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppPaddings.mediumSmall,
              vertical: AppPaddings.verticalSmallest,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(
                  AppLayout.radiusXxl),
            ),
            child: Text(
              product.category,
              style: AppTextStyles.labelMd.semiBold
                  .withColor(AppColors.primary),
            ),
          ),
          // Description
          if (product.description.isNotEmpty) ...[
            SizedBox(height: AppLayout.height16),
            Text(
              ProductStrings.productDescription,
              style: AppTextStyles.titleSm.bold,
            ),
            SizedBox(height: AppLayout.height8),
            Text(
              product.description,
              style: AppTextStyles.bodyMd
                  .withColor(AppColors.grayDark),
            ),
          ],
        ],
      ),
    );
  }
}
