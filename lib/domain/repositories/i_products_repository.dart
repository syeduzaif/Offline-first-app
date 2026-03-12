import 'package:offline_first_app/domain/models/product.dart';

abstract class IProductsRepository {
  Stream<List<Product>> watchProducts();
  Stream<Product?> watchProduct(int id);
  Future<int> refreshProducts({int limit = 20, int skip = 0});
  Stream<List<Product>> searchProducts(String query);
  Stream<List<Product>> watchProductsByCategory(String category);
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(int id);
  Future<Product?> getProduct(int id);
}
