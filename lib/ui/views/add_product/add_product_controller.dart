import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/providers/core_providers.dart';

class AddProductState {
  const AddProductState({
    this.selectedCategory,
    this.isLoading = false,
  });

  final String? selectedCategory;
  final bool isLoading;

  AddProductState copyWith({
    Object? selectedCategory = _sentinel,
    bool? isLoading,
  }) {
    return AddProductState(
      selectedCategory: selectedCategory == _sentinel
          ? this.selectedCategory
          : selectedCategory as String?,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

const _sentinel = Object();

class AddProductController extends Notifier<AddProductState> {
  @override
  AddProductState build() => const AddProductState();

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
      final product = Product(
        id: 0,
        title: title.trim(),
        description: description.trim(),
        price: price,
        brand: brand.trim(),
        stock: stock,
        category: state.selectedCategory!,
      );
      await ref
          .read(productsRepositoryProvider)
          .createProduct(product);
      ref.read(syncServiceProvider).syncAll().ignore();
      return null; // success
    } catch (_) {
      return ProductStrings.errorSaveFailed;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final addProductControllerProvider =
    NotifierProvider<AddProductController, AddProductState>(
  AddProductController.new,
);
