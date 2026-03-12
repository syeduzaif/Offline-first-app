import 'package:drift/drift.dart';
import 'package:offline_first_app/data/local/database.dart';
import 'package:offline_first_app/data/local/tables/products_table.dart';

part 'products_dao.g.dart';

@DriftAccessor(tables: [Products])
class ProductsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductsDaoMixin {
  ProductsDao(super.db);

  Stream<List<Product>> watchAllProducts() => (select(products)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.lastModified)]))
      .watch();

  Stream<Product?> watchProduct(int productId) =>
      (select(products)..where((t) => t.id.equals(productId)))
          .watchSingleOrNull();

  Stream<List<Product>> searchProducts(String query) =>
      (select(products)
            ..where((t) =>
                t.isDeleted.equals(false) &
                (t.title.contains(query) |
                    t.description.contains(query) |
                    t.brand.contains(query)))
            ..orderBy(
                [(t) => OrderingTerm.desc(t.lastModified)]))
          .watch();

  Stream<List<Product>> watchByCategory(String cat) =>
      (select(products)
            ..where((t) =>
                t.isDeleted.equals(false) &
                t.category.equals(cat))
            ..orderBy(
                [(t) => OrderingTerm.desc(t.lastModified)]))
          .watch();

  Future<int> upsertProduct(ProductsCompanion product) =>
      into(products).insertOnConflictUpdate(product);

  Future<void> upsertProducts(
      List<ProductsCompanion> items) async {
    await batch((b) {
      for (final item in items) {
        b.insert(
          products,
          item,
          onConflict: DoUpdate((_) => item),
        );
      }
    });
  }

  Future<void> softDeleteProduct(int productId) =>
      (update(products)
            ..where((t) => t.id.equals(productId)))
          .write(ProductsCompanion(
        isDeleted: const Value(true),
        syncStatus: const Value('pending'),
        lastModified: Value(DateTime.now()),
      ));

  Future<void> updateSyncStatus(
          int productId, String status) =>
      (update(products)
            ..where((t) => t.id.equals(productId)))
          .write(ProductsCompanion(
        syncStatus: Value(status),
      ));

  Future<Product?> getProduct(int productId) =>
      (select(products)
            ..where((t) => t.id.equals(productId)))
          .getSingleOrNull();

  Future<void> hardDeleteProduct(int productId) =>
      (delete(products)
            ..where((t) => t.id.equals(productId)))
          .go();

  Future<void> updateRemoteId(int localId, int remoteId) =>
      (update(products)
            ..where((t) => t.id.equals(localId)))
          .write(ProductsCompanion(
        remoteId: Value(remoteId),
        syncStatus: const Value('synced'),
      ));
}
