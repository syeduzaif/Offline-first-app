import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:offline_first_app/data/local/database.dart'
    hide Product;
import 'package:offline_first_app/data/local/database.dart'
    as db show Product;
import 'package:offline_first_app/data/local/daos/products_dao.dart';
import 'package:offline_first_app/data/local/daos/sync_queue_dao.dart';
import 'package:offline_first_app/data/remote/api_client.dart';
import 'package:offline_first_app/data/remote/dtos/product_dto.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/domain/models/sync_status.dart';
import 'package:offline_first_app/domain/repositories/i_products_repository.dart';

class ProductsRepository implements IProductsRepository {
  ProductsRepository({
    required this.productsDao,
    required this.syncQueueDao,
    required this.apiClient,
    required this.database,
  });

  final ProductsDao productsDao;
  final SyncQueueDao syncQueueDao;
  final ApiClient apiClient;
  final AppDatabase database;

  Product _toDomain(db.Product row) {
    List<String> images = [];
    try {
      final decoded = jsonDecode(row.images);
      if (decoded is List) {
        images = decoded.cast<String>();
      }
    } catch (_) {}

    return Product(
      id: row.id,
      title: row.title,
      description: row.description,
      price: row.price,
      discountPercentage: row.discountPercentage,
      rating: row.rating,
      stock: row.stock,
      brand: row.brand,
      category: row.category,
      thumbnail: row.thumbnail,
      images: images,
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == row.syncStatus,
        orElse: () => SyncStatus.synced,
      ),
      lastModified: row.lastModified,
      remoteId: row.remoteId,
    );
  }

  ProductsCompanion _dtoToCompanion(ProductDto dto) {
    return ProductsCompanion(
      id: Value(dto.id),
      title: Value(dto.title),
      description: Value(dto.description),
      price: Value(dto.price),
      discountPercentage: Value(dto.discountPercentage),
      rating: Value(dto.rating),
      stock: Value(dto.stock),
      brand: Value(dto.brand ?? ''),
      category: Value(dto.category),
      thumbnail: Value(dto.thumbnail ?? ''),
      images: Value(jsonEncode(dto.images)),
      syncStatus: const Value('synced'),
      lastModified: Value(DateTime.now()),
      remoteId: Value(dto.id),
      isDeleted: const Value(false),
    );
  }

  @override
  Stream<List<Product>> watchProducts() =>
      productsDao.watchAllProducts().map(
            (rows) => rows.map(_toDomain).toList(),
          );

  @override
  Stream<Product?> watchProduct(int id) =>
      productsDao.watchProduct(id).map(
            (row) => row != null ? _toDomain(row) : null,
          );

  @override
  Stream<List<Product>> searchProducts(String query) =>
      productsDao.searchProducts(query).map(
            (rows) => rows.map(_toDomain).toList(),
          );

  @override
  Stream<List<Product>> watchProductsByCategory(
          String category) =>
      productsDao.watchByCategory(category).map(
            (rows) => rows.map(_toDomain).toList(),
          );

  @override
  Future<int> refreshProducts({
    int limit = 20,
    int skip = 0,
  }) async {
    final response = await apiClient.getProducts(
      limit: limit,
      skip: skip,
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) return 0;

    final productsList =
        (data['products'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(ProductDto.fromJson)
            .toList();
    final companions =
        productsList.map(_dtoToCompanion).toList();
    await productsDao.upsertProducts(companions);
    return (data['total'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<Product> createProduct(Product product) async {
    final now = DateTime.now();
    final companion = ProductsCompanion(
      title: Value(product.title),
      description: Value(product.description),
      price: Value(product.price),
      discountPercentage:
          Value(product.discountPercentage),
      rating: Value(product.rating),
      stock: Value(product.stock),
      brand: Value(product.brand),
      category: Value(product.category),
      thumbnail: Value(product.thumbnail),
      images: Value(jsonEncode(product.images)),
      syncStatus: const Value('pending'),
      lastModified: Value(now),
      isDeleted: const Value(false),
    );

    final id =
        await productsDao.upsertProduct(companion);

    final payload = {
      'title': product.title,
      'description': product.description,
      'price': product.price,
      'discountPercentage': product.discountPercentage,
      'stock': product.stock,
      'brand': product.brand,
      'category': product.category,
    };

    await syncQueueDao.enqueue(SyncQueueCompanion(
      operation: const Value('create'),
      entityType: const Value('product'),
      entityId: Value(id),
      payload: Value(jsonEncode(payload)),
      createdAt: Value(now),
    ));

    return product.copyWith(
      id: id,
      syncStatus: SyncStatus.pending,
      lastModified: now,
      isLocalOnly: true,
    );
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final now = DateTime.now();
    final companion = ProductsCompanion(
      id: Value(product.id),
      title: Value(product.title),
      description: Value(product.description),
      price: Value(product.price),
      discountPercentage:
          Value(product.discountPercentage),
      rating: Value(product.rating),
      stock: Value(product.stock),
      brand: Value(product.brand),
      category: Value(product.category),
      thumbnail: Value(product.thumbnail),
      images: Value(jsonEncode(product.images)),
      syncStatus: const Value('pending'),
      lastModified: Value(now),
    );

    await productsDao.upsertProduct(companion);

    final payload = {
      'title': product.title,
      'description': product.description,
      'price': product.price,
      'discountPercentage': product.discountPercentage,
      'stock': product.stock,
      'brand': product.brand,
      'category': product.category,
    };

    await syncQueueDao.enqueue(SyncQueueCompanion(
      operation: const Value('update'),
      entityType: const Value('product'),
      entityId: Value(product.id),
      payload: Value(jsonEncode(payload)),
      createdAt: Value(now),
    ));

    return product.copyWith(
      syncStatus: SyncStatus.pending,
      lastModified: now,
    );
  }

  @override
  Future<void> deleteProduct(int id) async {
    await productsDao.softDeleteProduct(id);

    await syncQueueDao.enqueue(SyncQueueCompanion(
      operation: const Value('delete'),
      entityType: const Value('product'),
      entityId: Value(id),
      payload: const Value('{}'),
      createdAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<Product?> getProduct(int id) async {
    final row = await productsDao.getProduct(id);
    return row != null ? _toDomain(row) : null;
  }
}
