import 'package:drift/drift.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description =>
      text().withDefault(const Constant(''))();
  RealColumn get price => real()();
  RealColumn get discountPercentage =>
      real().withDefault(const Constant(0.0))();
  RealColumn get rating =>
      real().withDefault(const Constant(0.0))();
  IntColumn get stock =>
      integer().withDefault(const Constant(0))();
  TextColumn get brand =>
      text().withDefault(const Constant(''))();
  TextColumn get category =>
      text().withDefault(const Constant(''))();
  TextColumn get thumbnail =>
      text().withDefault(const Constant(''))();
  TextColumn get images =>
      text().withDefault(const Constant('[]'))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('synced'))();
  DateTimeColumn get lastModified =>
      dateTime().withDefault(currentDateAndTime)();
  IntColumn get remoteId => integer().nullable()();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();
}
