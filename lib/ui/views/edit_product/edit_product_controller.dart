import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/domain/models/category.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/providers/service_providers.dart';

class EditProductState {
  final List<ProductCategory> categories;
  final bool isLoading;

  const EditProductState({
    this.categories = const [],
    this.isLoading = false,
  });

  EditProductState copyWith({
    List<ProductCategory>? categories,
    bool? isLoading,
  }) {
    return EditProductState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class EditProductController extends StateNotifier<EditProductState> {
  EditProductController(this._ref, this._product)
      : super(const EditProductState());

  final Ref _ref;
  final Product _product;
  StreamSubscription<List<ProductCategory>>? _catSub;

  void initialize() {
    _catSub = _ref
        .read(categoriesRepositoryProvider)
        .watchCategories()
        .listen((cats) {
      state = state.copyWith(categories: cats);
    });
  }

  /// Validates and saves the updated product.
  /// Returns null on success or an error message on failure.
  Future<String?> saveProduct({
    required String title,
    required String description,
    required String price,
    required String brand,
    required String stock,
    required String? category,
  }) async {
    if (title.trim().isEmpty) return ProductStrings.errorTitleRequired;
    final priceVal = double.tryParse(price.trim());
    if (priceVal == null || priceVal < 0) {
      return ProductStrings.errorInvalidPrice;
    }
    final stockVal = int.tryParse(stock.trim());
    if (stockVal == null || stockVal < 0) {
      return ProductStrings.errorInvalidStock;
    }
    if (category == null || category.isEmpty) {
      return ProductStrings.errorCategoryRequired;
    }

    state = state.copyWith(isLoading: true);
    try {
      final updated = _product.copyWith(
        title: title.trim(),
        description: description.trim(),
        price: priceVal,
        brand: brand.trim(),
        stock: stockVal,
        category: category,
      );
      await _ref.read(productsRepositoryProvider).updateProduct(updated);
      _ref.read(syncServiceProvider).syncAll().ignore();
      return null;
    } catch (_) {
      return ProductStrings.errorSaveFailed;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  @override
  void dispose() {
    _catSub?.cancel();
    super.dispose();
  }
}

final editProductControllerProvider = StateNotifierProvider.autoDispose
    .family<EditProductController, EditProductState, Product>((ref, product) {
  final controller = EditProductController(ref, product);
  controller.initialize();
  return controller;
});
