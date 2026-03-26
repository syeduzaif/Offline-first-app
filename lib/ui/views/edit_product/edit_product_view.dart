import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/ui/views/add_product/widgets/product_form_wdiget.dart';
import 'package:offline_first_app/ui/views/edit_product/edit_product_state.dart';

class EditProductView extends ConsumerStatefulWidget {
  const EditProductView({
    super.key,
    required this.productId,
  });

  final int productId;

  @override
  ConsumerState<EditProductView> createState() =>
      _EditProductViewState();
}

class _EditProductViewState extends ConsumerState<EditProductView> {
  @override
  void initState() {
    super.initState();
    ref
        .read(editProductControllerProvider.notifier)
        .initialize(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProductControllerProvider);
    final controller =
        ref.read(editProductControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(ProductStrings.editProduct),
        actions: [
          TextButton(
            onPressed: () => controller.saveProduct(context),
            child: Text(
              CommonStrings.actionSave,
              style: const TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppPaddings.allBase,
        child: ProductForm(
          titleController: controller.titleController,
          descriptionController: controller.descriptionController,
          priceController: controller.priceController,
          brandController: controller.brandController,
          stockController: controller.stockController,
          categories: state.categories,
          selectedCategory: state.selectedCategory,
          onCategoryChanged: controller.onCategoryChanged,
        ),
      ),
    );
  }
}
