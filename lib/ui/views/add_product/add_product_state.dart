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
class AddProductState {
  const AddProductState({
    this.categories = const [],
    this.selectedCategory,
    this.isLoading = false,
  });

  final List<ProductCategory> categories;
  final String? selectedCategory;
  final bool isLoading;

  AddProductState copyWith({
    List<ProductCategory>? categories,
    String? selectedCategory,
    bool? isLoading,
  }) {
    return AddProductState(
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final addProductControllerProvider =
    NotifierProvider<AddProductController, AddProductState>(
  AddProductController.new,
);

class AddProductController extends Notifier<AddProductState> {
  late final ProductsRepository _productsRepo;
  late final CategoriesRepository _categoriesRepo;
  late final SyncService _syncService;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final brandController = TextEditingController();
  final stockController = TextEditingController();

  StreamSubscription<List<ProductCategory>>? _catSub;

  @override
  AddProductState build() {
    _productsRepo = ref.read(productsRepositoryProvider);
    _categoriesRepo = ref.read(categoriesRepositoryProvider);
    _syncService = ref.read(syncServiceProvider);

    _catSub =
        _categoriesRepo.watchCategories().listen((cats) {
      state = state.copyWith(categories: cats);
    });

    ref.onDispose(() {
      _catSub?.cancel();
      titleController.dispose();
      descriptionController.dispose();
      priceController.dispose();
      brandController.dispose();
      stockController.dispose();
    });

    return const AddProductState();
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

    final product = Product(
      id: 0,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      price: double.parse(priceController.text.trim()),
      brand: brandController.text.trim(),
      stock: int.parse(stockController.text.trim()),
      category: state.selectedCategory!,
    );

    _setLoading(true);
    try {
      await _productsRepo.createProduct(product);
      _syncService.syncAll().ignore();
      return const ProductFormSubmissionResult.success(
        ProductStrings.createSuccess,
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
