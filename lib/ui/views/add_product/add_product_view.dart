import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/ui/views/add_product/add_product_controller.dart';
import 'package:offline_first_app/ui/views/add_product/widgets/product_form_wdiget.dart';
import 'package:offline_first_app/ui/views/products/products_providers.dart';

class AddProductView extends ConsumerStatefulWidget {
  const AddProductView({super.key});

  @override
  ConsumerState<AddProductView> createState() =>
      _AddProductViewState();
}

class _AddProductViewState extends ConsumerState<AddProductView> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _brandController = TextEditingController();
  final _stockController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _brandController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final error = await ref
        .read(addProductControllerProvider.notifier)
        .saveProduct(
          title: _titleController.text,
          description: _descriptionController.text,
          priceText: _priceController.text,
          brand: _brandController.text,
          stockText: _stockController.text,
        );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(ProductStrings.createSuccess)),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addProductControllerProvider);
    final categories =
        ref.watch(categoriesProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(ProductStrings.addProduct),
        actions: [
          state.isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white),
                  ),
                )
              : TextButton(
                  onPressed: _save,
                  child: const Text(
                    CommonStrings.actionSave,
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppPaddings.allBase,
        child: ProductForm(
          titleController: _titleController,
          descriptionController: _descriptionController,
          priceController: _priceController,
          brandController: _brandController,
          stockController: _stockController,
          categories: categories,
          selectedCategory: state.selectedCategory,
          onCategoryChanged: ref
              .read(addProductControllerProvider.notifier)
              .selectCategory,
        ),
      ),
    );
  }
}
