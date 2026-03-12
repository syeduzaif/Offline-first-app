import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/domain/models/sync_status.dart';
import 'package:offline_first_app/ui/widgets/sync_badge_wdiget.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: AppPaddings.bottomSmall,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius:
              BorderRadius.circular(AppLayout.radiusMd),
          boxShadow: AppLayout.shadowSm,
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft:
                    Radius.circular(AppLayout.radiusMd),
                bottomLeft:
                    Radius.circular(AppLayout.radiusMd),
              ),
              child: SizedBox(
                width: AppLayout.width100,
                height: AppLayout.height100,
                child: product.thumbnail.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.thumbnail,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const _ImagePlaceholder(),
                        errorWidget: (context, url, error) =>
                            const _ImagePlaceholder(),
                      )
                    : const _ImagePlaceholder(),
              ),
            ),
            // Details
            Expanded(
              child: Padding(
                padding: AppPaddings.allMediumSmall,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // Title + sync badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.title,
                            style: AppTextStyles
                                .titleSm.semiBold,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        ),
                        if (product.syncStatus !=
                            SyncStatus.synced)
                          Padding(
                            padding: EdgeInsets.only(
                                left:
                                    AppPaddings.smallest),
                            child: SyncBadge(
                                status:
                                    product.syncStatus),
                          ),
                      ],
                    ),
                    SizedBox(height: AppLayout.height4),
                    // Brand
                    if (product.brand.isNotEmpty)
                      Text(
                        product.brand,
                        style: AppTextStyles.captionLg
                            .withColor(
                                AppColors.grayMedium),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: AppLayout.height8),
                    // Price + rating
                    Row(
                      children: [
                        Text(
                          ProductStrings.priceLabel(
                              product.price),
                          style: AppTextStyles
                              .titleSm.bold
                              .withColor(
                                  AppColors.primary),
                        ),
                        if (product.discountPercentage >
                            0) ...[
                          SizedBox(
                              width: AppLayout.width8),
                          Container(
                            padding:
                                EdgeInsets.symmetric(
                              horizontal:
                                  AppPaddings.smallest,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.failedBg,
                              borderRadius:
                                  BorderRadius.circular(
                                      AppLayout
                                          .radiusXs),
                            ),
                            child: Text(
                              ProductStrings
                                  .discountLabel(
                                      product
                                          .discountPercentage),
                              style: AppTextStyles
                                  .captionSm.bold
                                  .withColor(AppColors
                                      .discountRed),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Icon(
                          Iconsax.star1,
                          size: AppLayout.iconSizeSm,
                          color: AppColors.starYellow,
                        ),
                        SizedBox(
                            width: AppLayout.width4),
                        Text(
                          ProductStrings.ratingLabel(
                              product.rating),
                          style: AppTextStyles.captionLg
                              .semiBold,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.grayVeryLight,
      child: Icon(
        Iconsax.image,
        size: AppLayout.iconSizeLg,
        color: AppColors.grayLight,
      ),
    );
  }
}
