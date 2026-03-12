import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:offline_first_app/data/local/daos/categories_dao.dart';
import 'package:offline_first_app/data/local/daos/products_dao.dart';
import 'package:offline_first_app/data/local/daos/sync_queue_dao.dart';
import 'package:offline_first_app/data/local/tables/categories_table.dart';
import 'package:offline_first_app/data/local/tables/products_table.dart';
import 'package:offline_first_app/data/local/tables/sync_queue_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Products, SyncQueue, Categories],
  daos: [ProductsDao, SyncQueueDao, CategoriesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file =
        File(p.join(dbFolder.path, 'offline_first.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
