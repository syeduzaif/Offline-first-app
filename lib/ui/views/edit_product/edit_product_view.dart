import 'package:flutter/material.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/ui/views/add_product/widgets/product_form_wdiget.dart';
import 'package:offline_first_app/ui/views/edit_product/edit_product_viewmodel.dart';
import 'package:stacked/stacked.dart';

class EditProductView
    extends StackedView<EditProductViewModel> {
  const EditProductView({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  void onViewModelReady(EditProductViewModel viewModel) {
    viewModel.initialize(product);
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    EditProductViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ProductStrings.editProduct),
        actions: [
          TextButton(
            onPressed: viewModel.saveProduct,
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
          titleController: viewModel.titleController,
          descriptionController:
              viewModel.descriptionController,
          priceController: viewModel.priceController,
          brandController: viewModel.brandController,
          stockController: viewModel.stockController,
          categories: viewModel.categories,
          selectedCategory: viewModel.selectedCategory,
          onCategoryChanged: viewModel.onCategoryChanged,
        ),
      ),
    );
  }

  @override
  EditProductViewModel viewModelBuilder(
          BuildContext context) =>
      EditProductViewModel();
}
