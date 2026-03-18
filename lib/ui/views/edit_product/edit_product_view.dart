import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/ui/views/add_product/widgets/product_form_wdiget.dart';
import 'package:offline_first_app/ui/views/edit_product/edit_product_controller.dart';
import 'package:offline_first_app/ui/views/products/products_providers.dart';

class EditProductView extends ConsumerStatefulWidget {
  const EditProductView({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<EditProductView> createState() =>
      _EditProductViewState();
}

class _EditProductViewState
    extends ConsumerState<EditProductView> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _brandController;
  late final TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _titleController = TextEditingController(text: p.title);
    _descriptionController =
        TextEditingController(text: p.description);
    _priceController =
        TextEditingController(text: p.price.toString());
    _brandController = TextEditingController(text: p.brand);
    _stockController =
        TextEditingController(text: p.stock.toString());
  }

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
        .read(editProductControllerProvider(widget.product)
            .notifier)
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
            content: Text(ProductStrings.saveSuccess)),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref
        .watch(editProductControllerProvider(widget.product));
    final categories =
        ref.watch(categoriesProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(ProductStrings.editProduct),
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
              .read(editProductControllerProvider(
                      widget.product)
                  .notifier)
              .selectCategory,
        ),
      ),
    );
  }
}
