import 'dart:async';

import 'package:flutter/material.dart';
import 'package:offline_first_app/app/app.locator.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/core/viewmodels/app_viewmodel.dart';
import 'package:offline_first_app/data/repositories/categories_repository.dart';
import 'package:offline_first_app/data/repositories/products_repository.dart';
import 'package:offline_first_app/domain/models/category.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/services/sync_service.dart';
import 'package:stacked_services/stacked_services.dart' show NavigationService, StackedService;

class EditProductViewModel extends AppViewModel {
  final _productsRepo = locator<ProductsRepository>();
  final _categoriesRepo = locator<CategoriesRepository>();
  final _navigationService = locator<NavigationService>();
  final _syncService = locator<SyncService>();

  void _showSnackbar(String message) {
    final context =
        StackedService.navigatorKey?.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  late Product _product;

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

  void initialize(Product product) {
    _product = product;
    titleController.text = product.title;
    descriptionController.text = product.description;
    priceController.text = product.price.toString();
    brandController.text = product.brand;
    stockController.text = product.stock.toString();
    _selectedCategory = product.category.isNotEmpty
        ? product.category
        : null;

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

  Future<void> saveProduct() async {
    final title = titleController.text.trim();
    if (title.isEmpty) return;

    final updated = _product.copyWith(
      title: title,
      description: descriptionController.text.trim(),
      price:
          double.tryParse(priceController.text.trim()) ??
              _product.price,
      brand: brandController.text.trim(),
      stock:
          int.tryParse(stockController.text.trim()) ??
              _product.stock,
      category: _selectedCategory ?? _product.category,
    );

    try {
      await _productsRepo.updateProduct(updated);
      _syncService.syncAll();
      _showSnackbar(ProductStrings.saveSuccess);
    } catch (e) {
      _showSnackbar('Failed to save: $e');
    } finally {
      _navigationService.back();
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
