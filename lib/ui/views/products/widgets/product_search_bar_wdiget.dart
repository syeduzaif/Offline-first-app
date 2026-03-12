import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';

class ProductSearchBar extends StatelessWidget {
  const ProductSearchBar({
    super.key,
    required this.onChanged,
  });

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppPaddings.horizontalBase,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular(AppLayout.radiusMd),
        boxShadow: AppLayout.shadowSm,
      ),
      child: TextField(
        onChanged: onChanged,
        style: AppTextStyles.bodyMd,
        decoration: InputDecoration(
          hintText: ProductStrings.searchProducts,
          hintStyle: AppTextStyles.bodyMd
              .withColor(AppColors.grayLight),
          prefixIcon: Icon(
            Iconsax.search_normal,
            size: AppLayout.iconSizeMdSm,
            color: AppColors.grayMedium,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppPaddings.base,
            vertical: AppPaddings.verticalMedium,
          ),
        ),
      ),
    );
  }
}
