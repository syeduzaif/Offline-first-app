import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/core/di/providers.dart';
import 'package:offline_first_app/data/repositories/categories_repository.dart';
import 'package:offline_first_app/data/repositories/products_repository.dart';
import 'package:offline_first_app/domain/models/category.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/services/sync_service.dart';

@immutable
class EditProductState {
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
    Product? product,
    List<ProductCategory>? categories,
    String? selectedCategory,
    bool? isLoading,
  }) {
    return EditProductState(
      product: product ?? this.product,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final editProductControllerProvider =
    NotifierProvider<EditProductController, EditProductState>(
  EditProductController.new,
);

class EditProductController extends Notifier<EditProductState> {
  late final ProductsRepository _productsRepo;
  late final CategoriesRepository _categoriesRepo;
  late final SyncService _syncService;

  int? _productId;
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

    _catSub =
        _categoriesRepo.watchCategories().listen((cats) {
      state = state.copyWith(categories: cats);
    });

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

  void initialize(int productId) {
    if (_productId == productId && _productSub != null) {
      return;
    }
    _productId = productId;
    _didInitFields = false;
    _productSub?.cancel();
    _productSub =
        _productsRepo.watchProduct(productId).listen(_onProductChanged);
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
    if (titleController.text.trim().isEmpty) {
      return ProductStrings.errorTitleRequired;
    }
    final price =
        double.tryParse(priceController.text.trim());
    if (price == null || price < 0) {
      return ProductStrings.errorInvalidPrice;
    }
    final stock =
        int.tryParse(stockController.text.trim());
    if (stock == null || stock < 0) {
      return ProductStrings.errorInvalidStock;
    }
    if (state.selectedCategory == null ||
        state.selectedCategory!.isEmpty) {
      return ProductStrings.errorCategoryRequired;
    }
    return null;
  }

  Future<void> saveProduct(BuildContext context) async {
    final validationError = _validate();
    if (validationError != null) {
      _showSnack(context, validationError);
      return;
    }
    final current = state.product;
    if (current == null) {
      _showSnack(context, ProductStrings.errorSaveFailed);
      return;
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
      if (!context.mounted) return;
      _showSnack(context, ProductStrings.saveSuccess);
      context.pop();
    } catch (_) {
      if (!context.mounted) return;
      _showSnack(context, ProductStrings.errorSaveFailed);
    } finally {
      _setLoading(false);
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }
}
