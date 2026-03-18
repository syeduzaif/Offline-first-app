import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/providers/core_providers.dart';

class EditProductState {
  const EditProductState({
    required this.product,
    this.selectedCategory,
    this.isLoading = false,
  });

  final Product product;
  final String? selectedCategory;
  final bool isLoading;

  EditProductState copyWith({
    Object? selectedCategory = _sentinel,
    bool? isLoading,
  }) {
    return EditProductState(
      product: product,
      selectedCategory: selectedCategory == _sentinel
          ? this.selectedCategory
          : selectedCategory as String?,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

const _sentinel = Object();

class EditProductController
    extends FamilyNotifier<EditProductState, Product> {
  @override
  EditProductState build(Product arg) {
    return EditProductState(
      product: arg,
      selectedCategory:
          arg.category.isNotEmpty ? arg.category : null,
    );
  }

  void selectCategory(String? slug) {
    state = state.copyWith(selectedCategory: slug);
  }

  /// Returns an error message on failure, or null on success.
  Future<String?> saveProduct({
    required String title,
    required String description,
    required String priceText,
    required String brand,
    required String stockText,
  }) async {
    if (title.trim().isEmpty) {
      return ProductStrings.errorTitleRequired;
    }
    final price = double.tryParse(priceText.trim());
    if (price == null || price < 0) {
      return ProductStrings.errorInvalidPrice;
    }
    final stock = int.tryParse(stockText.trim());
    if (stock == null || stock < 0) {
      return ProductStrings.errorInvalidStock;
    }
    if (state.selectedCategory == null ||
        state.selectedCategory!.isEmpty) {
      return ProductStrings.errorCategoryRequired;
    }

    state = state.copyWith(isLoading: true);
    try {
      final updated = state.product.copyWith(
        title: title.trim(),
        description: description.trim(),
        price: price,
        brand: brand.trim(),
        stock: stock,
        category: state.selectedCategory!,
      );
      await ref
          .read(productsRepositoryProvider)
          .updateProduct(updated);
      ref.read(syncServiceProvider).syncAll().ignore();
      return null; // success
    } catch (_) {
      return ProductStrings.errorSaveFailed;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final editProductControllerProvider = NotifierProvider.family<
    EditProductController, EditProductState, Product>(
  EditProductController.new,
);
