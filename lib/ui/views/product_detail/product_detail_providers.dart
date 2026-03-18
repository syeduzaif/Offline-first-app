import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/providers/core_providers.dart';

/// Live stream of a single product by its local ID.
final productDetailProvider =
    StreamProvider.family<Product?, int>((ref, productId) {
  return ref.watch(productsRepositoryProvider).watchProduct(productId);
});
