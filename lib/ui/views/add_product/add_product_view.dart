import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/ui/views/add_product/add_product_state.dart';
import 'package:offline_first_app/ui/views/add_product/widgets/product_form_wdiget.dart';

class AddProductView extends ConsumerStatefulWidget {
  const AddProductView({super.key});

  @override
  ConsumerState<AddProductView> createState() =>
      _AddProductViewState();
}

class _AddProductViewState extends ConsumerState<AddProductView> {
  @override
  void initState() {
    super.initState();
    ref.read(addProductControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addProductControllerProvider);
    final controller =
        ref.read(addProductControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(ProductStrings.addProduct),
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
