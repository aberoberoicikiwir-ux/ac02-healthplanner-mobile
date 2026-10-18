import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Penyimpanan RAHASIA (token & kredensial) -> flutter_secure_storage.
/// Di Android data dienkripsi memakai Keystore, jadi aman walau app di-update.
class SecureStorageService {
  static const _tokenKey = 'access_token';
  static const _usernameKey = 'username';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveSession({
    required String token,
    required String username,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _usernameKey, value: username);
  }

  Future<String?> readToken() => _storage.read(key: _tokenKey);
  Future<String?> readUsername() => _storage.read(key: _usernameKey);

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _usernameKey);
  }
}
