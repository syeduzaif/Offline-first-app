import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/ui/views/add_product/add_product_state.dart';
import 'package:offline_first_app/ui/views/add_product/widgets/product_form_wdiget.dart';

class AddProductView extends ConsumerWidget {
  const AddProductView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addProductControllerProvider);
    final controller =
        ref.read(addProductControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(ProductStrings.addProduct),
        actions: [
          TextButton(
            onPressed: state.isLoading
                ? null
                : () => _saveProduct(context, controller),
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

  Future<void> _saveProduct(
    BuildContext context,
    AddProductController controller,
  ) async {
    final result = await controller.saveProduct();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );

    if (result.didSucceed) {
      context.pop();
    }
  }
}
