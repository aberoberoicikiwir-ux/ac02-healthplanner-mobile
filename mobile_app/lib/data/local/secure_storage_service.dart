import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Penyimpanan RAHASIA (token & kredensial) -> flutter_secure_storage.
/// Di Android data dienkripsi memakai Keystore, jadi aman walau app di-update.
class SecureStorageService {
  static const _tokenKey = 'access_token';
  static const _usernameKey = 'username';
  static const _nameKey = 'display_name';
  static const _userIdKey = 'user_id';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveSession({
    required String token,
    required String name,
    String? username,
    int? userId,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _nameKey, value: name);
    if (username != null) {
      await _storage.write(key: _usernameKey, value: username);
    }
    if (userId != null) {
      await _storage.write(key: _userIdKey, value: userId.toString());
    }
  }

  Future<String?> readToken() => _storage.read(key: _tokenKey);
  Future<String?> readUsername() => _storage.read(key: _usernameKey);
  Future<String?> readName() => _storage.read(key: _nameKey);
  Future<int?> readUserId() async {
    final value = await _storage.read(key: _userIdKey);
    return value == null ? null : int.tryParse(value);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _nameKey);
    await _storage.delete(key: _userIdKey);
  }
}
