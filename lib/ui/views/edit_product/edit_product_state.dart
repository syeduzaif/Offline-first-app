import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/core/di/providers.dart';
import 'package:offline_first_app/data/repositories/categories_repository.dart';
import 'package:offline_first_app/data/repositories/products_repository.dart';
import 'package:offline_first_app/domain/models/category.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/services/sync_service.dart';
import 'package:offline_first_app/ui/views/product_form/product_form_submission_result.dart';
import 'package:offline_first_app/ui/views/product_form/product_form_validator.dart';

@immutable
class EditProductState {
  static const Object _unset = Object();

  const EditProductState({
    this.product,
    this.categories = const [],
    this.selectedCategory,
    this.isLoading = false,
  });

  final Product? product;
  final List<ProductCategory> categories;
  final String? selectedCategory;
  final bool isLoading;

  EditProductState copyWith({
    Object? product = _unset,
    List<ProductCategory>? categories,
    Object? selectedCategory = _unset,
    bool? isLoading,
  }) {
    return EditProductState(
      product: identical(product, _unset)
          ? this.product
          : product as Product?,
      categories: categories ?? this.categories,
      selectedCategory: identical(selectedCategory, _unset)
          ? this.selectedCategory
          : selectedCategory as String?,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Family key is the productId — one isolated provider instance per product.
final editProductControllerProvider = NotifierProvider.family<
    EditProductController, EditProductState, int>(
  (productId) => EditProductController(productId),
);

class EditProductController extends Notifier<EditProductState> {
  EditProductController(this._productId);

  final int _productId;

  late final ProductsRepository _productsRepo;
  late final CategoriesRepository _categoriesRepo;
  late final SyncService _syncService;

  // Prevents re-populating text fields on every product stream event.
  bool _didInitFields = false;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final brandController = TextEditingController();
  final stockController = TextEditingController();

  StreamSubscription<List<ProductCategory>>? _catSub;
  StreamSubscription<Product?>? _productSub;

  @override
  EditProductState build() {
    _productsRepo = ref.read(productsRepositoryProvider);
    _categoriesRepo = ref.read(categoriesRepositoryProvider);
    _syncService = ref.read(syncServiceProvider);

    _catSub = _categoriesRepo.watchCategories().listen((cats) {
      state = state.copyWith(categories: cats);
    });

    _productSub =
        _productsRepo.watchProduct(_productId).listen(_onProductChanged);

    ref.onDispose(() {
      _catSub?.cancel();
      _productSub?.cancel();
      titleController.dispose();
      descriptionController.dispose();
      priceController.dispose();
      brandController.dispose();
      stockController.dispose();
    });

    return const EditProductState();
  }

  void _onProductChanged(Product? product) {
    if (product != null && !_didInitFields) {
      _didInitFields = true;
      titleController.text = product.title;
      descriptionController.text = product.description;
      priceController.text = product.price.toString();
      brandController.text = product.brand;
      stockController.text = product.stock.toString();
    }

    state = state.copyWith(
      product: product,
      selectedCategory: product?.category.isNotEmpty == true
          ? product!.category
          : state.selectedCategory,
    );
  }

  void onCategoryChanged(String? slug) {
    state = state.copyWith(selectedCategory: slug);
  }

  String? _validate() {
    return ProductFormValidator.validate(
      title: titleController.text,
      price: priceController.text,
      stock: stockController.text,
      selectedCategory: state.selectedCategory,
    );
  }

  Future<ProductFormSubmissionResult> saveProduct() async {
    final validationError = _validate();
    if (validationError != null) {
      return ProductFormSubmissionResult.failure(validationError);
    }
    final current = state.product;
    if (current == null) {
      return const ProductFormSubmissionResult.failure(
        ProductStrings.errorSaveFailed,
      );
    }

    final updated = current.copyWith(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      price: double.parse(priceController.text.trim()),
      brand: brandController.text.trim(),
      stock: int.parse(stockController.text.trim()),
      category: state.selectedCategory!,
    );

    _setLoading(true);
    try {
      await _productsRepo.updateProduct(updated);
      _syncService.syncAll().ignore();
      return const ProductFormSubmissionResult.success(
        ProductStrings.saveSuccess,
      );
    } catch (_) {
      return const ProductFormSubmissionResult.failure(
        ProductStrings.errorSaveFailed,
      );
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }
}
