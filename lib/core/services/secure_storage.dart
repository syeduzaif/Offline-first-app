import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _dbKeyName    = 'db_encryption_key';
  static const _authTokenKey = 'auth_token';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<String> getDatabaseKey() async {
    var key = await _storage.read(key: _dbKeyName);
    if (key == null) {
      key = _generateHexKey();
      await _storage.write(key: _dbKeyName, value: key);
    }
    return key;
  }

  Future<void> saveAuthToken(String token) =>
      _storage.write(key: _authTokenKey, value: token);

  Future<String?> getAuthToken() => _storage.read(key: _authTokenKey);

  Future<void> clearAuthToken() => _storage.delete(key: _authTokenKey);

  String _generateHexKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
