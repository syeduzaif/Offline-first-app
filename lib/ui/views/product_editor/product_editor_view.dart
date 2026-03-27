import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/core/providers/providers.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/ui/views/add_product/widgets/product_form_wdiget.dart';

class ProductEditorView extends ConsumerStatefulWidget {
  const ProductEditorView({
    super.key,
    required this.title,
    required this.successMessage,
    this.initialProduct,
  });

  final String title;
  final String successMessage;
  final Product? initialProduct;

  bool get isEditing => initialProduct != null;

  @override
  ConsumerState<ProductEditorView> createState() =>
      _ProductEditorViewState();
}

class _ProductEditorViewState
    extends ConsumerState<ProductEditorView> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _brandController;
  late final TextEditingController _stockController;

  String? _selectedCategory;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final product = widget.initialProduct;
    _titleController = TextEditingController(
      text: product?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    _brandController = TextEditingController(
      text: product?.brand ?? '',
    );
    _stockController = TextEditingController(
      text: product?.stock.toString() ?? '',
    );
    _selectedCategory = product?.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _brandController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_titleController.text.trim().isEmpty) {
      return ProductStrings.errorTitleRequired;
    }

    final price =
        double.tryParse(_priceController.text.trim());
    if (price == null || price < 0) {
      return ProductStrings.errorInvalidPrice;
    }

    final stock =
        int.tryParse(_stockController.text.trim());
    if (stock == null || stock < 0) {
      return ProductStrings.errorInvalidStock;
    }

    if (_selectedCategory == null ||
        _selectedCategory!.isEmpty) {
      return ProductStrings.errorCategoryRequired;
    }

    return null;
  }

  Product _buildProduct() {
    final existing = widget.initialProduct;
    if (existing != null) {
      return existing.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        brand: _brandController.text.trim(),
        stock: int.parse(_stockController.text.trim()),
        category: _selectedCategory!,
      );
    }

    return Product(
      id: 0,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      brand: _brandController.text.trim(),
      stock: int.parse(_stockController.text.trim()),
      category: _selectedCategory!,
    );
  }

  Future<void> _saveProduct() async {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repository = ref.read(productsRepositoryProvider);
      final product = _buildProduct();

      if (widget.isEditing) {
        await repository.updateProduct(product);
      } else {
        await repository.createProduct(product);
      }

      ref.read(syncServiceProvider).syncAll().ignore();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.successMessage)),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(ProductStrings.errorSaveFailed),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categories = categoriesAsync.valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProduct,
            child: Text(
              CommonStrings.actionSave,
              style: const TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppPaddings.allBase,
        child: categoriesAsync.hasError
            ? const Center(
                child: Text(CommonStrings.labelError),
              )
            : ProductForm(
                titleController: _titleController,
                descriptionController: _descriptionController,
                priceController: _priceController,
                brandController: _brandController,
                stockController: _stockController,
                categories: categories,
                selectedCategory: _selectedCategory,
                onCategoryChanged: (slug) =>
                    setState(() => _selectedCategory = slug),
              ),
      ),
    );
  }
}
