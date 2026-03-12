import 'package:flutter/material.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/ui/views/add_product/add_product_viewmodel.dart';
import 'package:offline_first_app/ui/views/add_product/widgets/product_form_wdiget.dart';
import 'package:stacked/stacked.dart';

class AddProductView
    extends StackedView<AddProductViewModel> {
  const AddProductView({super.key});

  @override
  void onViewModelReady(AddProductViewModel viewModel) {
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    AddProductViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ProductStrings.addProduct),
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
  AddProductViewModel viewModelBuilder(
          BuildContext context) =>
      AddProductViewModel();
}
