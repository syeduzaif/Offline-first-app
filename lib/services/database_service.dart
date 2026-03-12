import 'package:offline_first_app/data/local/database.dart';

class DatabaseService {
  late final AppDatabase _database;

  AppDatabase get database => _database;

  Future<void> initialize() async {
    _database = AppDatabase();
  }
}
