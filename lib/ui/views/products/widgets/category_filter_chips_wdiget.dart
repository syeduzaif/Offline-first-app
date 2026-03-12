import 'package:flutter/material.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/domain/models/category.dart';

class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({
    super.key,
    required this.categories,
    required this.selectedSlug,
    required this.onSelected,
  });

  final List<ProductCategory> categories;
  final String? selectedSlug;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppLayout.height42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppPaddings.horizontalBase,
        itemCount: categories.length + 1,
        separatorBuilder: (context, index) =>
            SizedBox(width: AppLayout.width8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _Chip(
              label: ProductStrings.allCategories,
              isSelected: selectedSlug == null,
              onTap: () => onSelected(null),
            );
          }
          final cat = categories[index - 1];
          return _Chip(
            label: cat.name,
            isSelected: selectedSlug == cat.slug,
            onTap: () => onSelected(cat.slug),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppPaddings.mediumSmall,
          vertical: AppPaddings.verticalBase,
        ),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary : AppColors.white,
          borderRadius:
              BorderRadius.circular(AppLayout.radiusXxl),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.grayVeryLight,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMd.semiBold.withColor(
            isSelected
                ? AppColors.white
                : AppColors.grayDark,
          ),
        ),
      ),
    );
  }
}
