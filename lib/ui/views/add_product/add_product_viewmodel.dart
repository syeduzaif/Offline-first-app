import 'dart:async';

import 'package:offline_first_app/app/app.locator.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/core/viewmodels/app_viewmodel.dart';
import 'package:offline_first_app/data/repositories/categories_repository.dart';
import 'package:offline_first_app/data/repositories/products_repository.dart';
import 'package:offline_first_app/domain/models/category.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/services/sync_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

class AddProductViewModel extends AppViewModel {
  final _productsRepo = locator<ProductsRepository>();
  final _categoriesRepo = locator<CategoriesRepository>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  final _syncService = locator<SyncService>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final brandController = TextEditingController();
  final stockController = TextEditingController();

  List<ProductCategory> _categories = [];
  List<ProductCategory> get categories => _categories;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  StreamSubscription<List<ProductCategory>>? _catSub;

  void initialize() {
    _catSub =
        _categoriesRepo.watchCategories().listen((cats) {
      _categories = cats;
      notifyListeners();
    });
  }

  void onCategoryChanged(String? slug) {
    _selectedCategory = slug;
    notifyListeners();
  }

  /// Returns a validation error message, or null if all fields are valid.
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
    if (_selectedCategory == null ||
        _selectedCategory!.isEmpty) {
      return ProductStrings.errorCategoryRequired;
    }
    return null;
  }

  Future<void> saveProduct() async {
    final validationError = _validate();
    if (validationError != null) {
      _snackbarService.showSnackbar(
          message: validationError);
      return;
    }

    final product = Product(
      id: 0,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      price: double.parse(priceController.text.trim()),
      brand: brandController.text.trim(),
      stock: int.parse(stockController.text.trim()),
      category: _selectedCategory!,
    );

    setLoading(true);
    try {
      await _productsRepo.createProduct(product);
      // Fire-and-forget: ConnectivityService also triggers
      // syncAll on reconnect; sync queue handles retry on failure.
      _syncService.syncAll().ignore();
      _snackbarService.showSnackbar(
          message: ProductStrings.createSuccess);
      _navigationService.back();
    } catch (_) {
      _snackbarService.showSnackbar(
          message: ProductStrings.errorSaveFailed);
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    _catSub?.cancel();
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    brandController.dispose();
    stockController.dispose();
    super.dispose();
  }
}
