import 'package:flutter/material.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/app_text_styles.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/domain/models/category.dart';

class ProductForm extends StatelessWidget {
  const ProductForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.priceController,
    required this.brandController,
    required this.stockController,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController brandController;
  final TextEditingController stockController;
  final List<ProductCategory> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField(
          label: ProductStrings.productTitle,
          controller: titleController,
        ),
        SizedBox(height: AppLayout.height16),
        _buildField(
          label: ProductStrings.productDescription,
          controller: descriptionController,
          maxLines: 3,
        ),
        SizedBox(height: AppLayout.height16),
        Row(
          children: [
            Expanded(
              child: _buildField(
                label: ProductStrings.productPrice,
                controller: priceController,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: AppLayout.width12),
            Expanded(
              child: _buildField(
                label: ProductStrings.productStock,
                controller: stockController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: AppLayout.height16),
        _buildField(
          label: ProductStrings.productBrand,
          controller: brandController,
        ),
        SizedBox(height: AppLayout.height16),
        // Category dropdown
        Text(
          ProductStrings.productCategory,
          style: AppTextStyles.labelMd.semiBold
              .withColor(AppColors.grayDark),
        ),
        SizedBox(height: AppLayout.height8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius:
                BorderRadius.circular(AppLayout.radiusMd),
            border: Border.all(
                color: AppColors.grayVeryLight),
          ),
          padding: AppPaddings.horizontalBase,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedCategory,
              hint: Text(
                ProductStrings.productCategory,
                style: AppTextStyles.bodyMd
                    .withColor(AppColors.grayLight),
              ),
              items: categories
                  .map((c) => DropdownMenuItem(
                        value: c.slug,
                        child: Text(c.name,
                            style: AppTextStyles.bodyMd),
                      ))
                  .toList(),
              onChanged: onCategoryChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMd.semiBold
              .withColor(AppColors.grayDark),
        ),
        SizedBox(height: AppLayout.height8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMd,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: AppTextStyles.bodyMd
                .withColor(AppColors.grayLight),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppPaddings.base,
              vertical: AppPaddings.verticalMedium,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppLayout.radiusMd),
              borderSide: BorderSide(
                  color: AppColors.grayVeryLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppLayout.radiusMd),
              borderSide: BorderSide(
                  color: AppColors.grayVeryLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppLayout.radiusMd),
              borderSide: const BorderSide(
                  color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
