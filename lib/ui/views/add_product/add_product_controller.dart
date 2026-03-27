import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/domain/models/category.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/providers/service_providers.dart';

class AddProductState {
  final List<ProductCategory> categories;
  final bool isLoading;

  const AddProductState({
    this.categories = const [],
    this.isLoading = false,
  });

  AddProductState copyWith({
    List<ProductCategory>? categories,
    bool? isLoading,
  }) {
    return AddProductState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AddProductController extends StateNotifier<AddProductState> {
  AddProductController(this._ref) : super(const AddProductState());

  final Ref _ref;
  StreamSubscription<List<ProductCategory>>? _catSub;

  void initialize() {
    _catSub = _ref
        .read(categoriesRepositoryProvider)
        .watchCategories()
        .listen((cats) {
      state = state.copyWith(categories: cats);
    });
  }

  /// Validates and saves the product.
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
      final product = Product(
        id: 0,
        title: title.trim(),
        description: description.trim(),
        price: priceVal,
        brand: brand.trim(),
        stock: stockVal,
        category: category,
      );
      await _ref.read(productsRepositoryProvider).createProduct(product);
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

final addProductControllerProvider = StateNotifierProvider.autoDispose<
    AddProductController, AddProductState>((ref) {
  final controller = AddProductController(ref);
  controller.initialize();
  return controller;
});
