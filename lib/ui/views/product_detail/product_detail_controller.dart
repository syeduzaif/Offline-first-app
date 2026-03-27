import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/providers/service_providers.dart';

/// Watches a single product by ID from the local database.
final productProvider =
    StreamProvider.family<Product?, int>((ref, productId) {
  return ref.watch(productsRepositoryProvider).watchProduct(productId);
});

class ProductDetailController extends StateNotifier<bool> {
  ProductDetailController(this._ref) : super(false);

  final Ref _ref;

  /// Deletes the product. Returns true on success.
  Future<bool> deleteProduct(int productId) async {
    try {
      await _ref.read(productsRepositoryProvider).deleteProduct(productId);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final productDetailControllerProvider =
    StateNotifierProvider<ProductDetailController, bool>((ref) {
  return ProductDetailController(ref);
});
