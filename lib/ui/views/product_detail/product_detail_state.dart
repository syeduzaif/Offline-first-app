import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/core/di/providers.dart';
import 'package:offline_first_app/data/repositories/products_repository.dart';
import 'package:offline_first_app/domain/models/product.dart';

@immutable
class ProductDetailState {
  static const Object _unset = Object();

  const ProductDetailState({this.product});

  final Product? product;

  ProductDetailState copyWith({Object? product = _unset}) {
    return ProductDetailState(
      product: identical(product, _unset)
          ? this.product
          : product as Product?,
    );
  }
}

// Family key is the productId — one isolated provider instance per product.
final productDetailControllerProvider = NotifierProvider.family<
    ProductDetailController, ProductDetailState, int>(
  (productId) => ProductDetailController(productId),
);

class ProductDetailController extends Notifier<ProductDetailState> {
  ProductDetailController(this._productId);

  final int _productId;

  late final ProductsRepository _productsRepo;
  StreamSubscription<Product?>? _productSub;

  @override
  ProductDetailState build() {
    _productsRepo = ref.read(productsRepositoryProvider);

    _productSub = _productsRepo.watchProduct(_productId).listen((p) {
      state = state.copyWith(product: p);
    });

    ref.onDispose(() {
      _productSub?.cancel();
    });

    return const ProductDetailState();
  }

  /// Throws on failure so the call site can surface an error to the user.
  Future<void> deleteProduct() async {
    final product = state.product;
    if (product == null) return;
    await _productsRepo.deleteProduct(product.id);
  }
}
