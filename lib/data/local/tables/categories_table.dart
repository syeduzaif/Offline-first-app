import 'package:drift/drift.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get slug => text().unique()();
  TextColumn get name => text()();
  TextColumn get url =>
      text().withDefault(const Constant(''))();
  DateTimeColumn get lastFetched =>
      dateTime().withDefault(currentDateAndTime)();
}
