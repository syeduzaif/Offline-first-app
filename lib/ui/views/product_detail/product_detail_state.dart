import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/core/di/providers.dart';
import 'package:offline_first_app/data/repositories/products_repository.dart';
import 'package:offline_first_app/domain/models/product.dart';

class ProductDetailState {
  const ProductDetailState({this.product});

  final Product? product;

  ProductDetailState copyWith({Product? product}) {
    return ProductDetailState(product: product ?? this.product);
  }
}

final productDetailControllerProvider =
    NotifierProvider<ProductDetailController, ProductDetailState>(
  ProductDetailController.new,
);

class ProductDetailController extends Notifier<ProductDetailState> {
  late final ProductsRepository _productsRepo;
  StreamSubscription<Product?>? _productSub;
  int? _productId;

  @override
  ProductDetailState build() {
    _productsRepo = ref.read(productsRepositoryProvider);

    ref.onDispose(() {
      _productSub?.cancel();
    });

    return const ProductDetailState();
  }

  void initialize(int productId) {
    if (_productId == productId && _productSub != null) {
      return;
    }
    _productId = productId;
    _productSub?.cancel();
    _productSub =
        _productsRepo.watchProduct(productId).listen((p) {
      state = state.copyWith(product: p);
    });
  }

  Future<void> deleteProduct() async {
    final product = state.product;
    if (product == null) return;
    await _productsRepo.deleteProduct(product.id);
  }
}
