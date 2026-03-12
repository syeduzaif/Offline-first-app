import 'package:drift/drift.dart';
import 'package:offline_first_app/data/local/database.dart';
import 'package:offline_first_app/data/local/tables/categories_table.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Stream<List<Category>> watchAll() => (select(categories)
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();

  Future<void> replaceAll(
      List<CategoriesCompanion> items) async {
    await transaction(() async {
      await delete(categories).go();
      await batch((b) {
        for (final item in items) {
          b.insert(categories, item);
        }
      });
    });
  }
}
