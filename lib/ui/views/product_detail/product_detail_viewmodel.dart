import 'dart:async';

import 'package:offline_first_app/app/app.locator.dart';
import 'package:offline_first_app/app/app.router.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/core/viewmodels/app_viewmodel.dart';
import 'package:offline_first_app/data/repositories/products_repository.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:stacked_services/stacked_services.dart';

class ProductDetailViewModel extends AppViewModel {
  final _productsRepo = locator<ProductsRepository>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  final _dialogService = locator<DialogService>();

  Product? _product;
  Product? get product => _product;

  StreamSubscription<Product?>? _productSub;

  void initialize(int productId) {
    _productSub =
        _productsRepo.watchProduct(productId).listen((p) {
      _product = p;
      notifyListeners();
    });
  }

  void navigateToEdit() {
    if (_product == null) return;
    _navigationService.navigateTo(
      Routes.editProductView,
      arguments:
          EditProductViewArguments(product: _product!),
    );
  }

  Future<void> deleteProduct() async {
    if (_product == null) return;
    final result = await _dialogService.showConfirmationDialog(
      title: ProductStrings.deleteProduct,
      description: ProductStrings.confirmDelete,
      confirmationTitle: CommonStrings.actionDelete,
      cancelTitle: CommonStrings.actionCancel,
    );
    if (result?.confirmed != true) return;

    await _productsRepo.deleteProduct(_product!.id);
    _snackbarService.showSnackbar(
      message: ProductStrings.deleteSuccess,
    );
    _navigationService.back();
  }

  @override
  void dispose() {
    _productSub?.cancel();
    super.dispose();
  }
}
