import 'package:drift/drift.dart';

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operation => text()();
  TextColumn get entityType => text()();
  IntColumn get entityId => integer()();
  TextColumn get payload => text()();
  TextColumn get status =>
      text().withDefault(const Constant('pending'))();
  IntColumn get retryCount =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  TextColumn get errorMessage => text().nullable()();
}
