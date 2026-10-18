import 'package:flutter/material.dart';
import '../data/local/secure_storage_service.dart';
import '../data/remote/fake_api_service.dart';

/// Global State untuk status login. Token disimpan di secure storage.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._api, this._secureStorage);

  final FakeApiService _api;
  final SecureStorageService _secureStorage;

  bool _isLoggedIn = false;
  String? _username;
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  String? get errorMessage => _errorMessage;

  /// Dipanggil sekali saat app dibuka: kalau token masih ada, anggap sudah login.
   Future<void> restoreSession() async {
    final token = await _secureStorage.readToken();
    debugPrint('DEBUG restoreSession: token ada? ${token != null}');
    if (token != null) {
      _isLoggedIn = true;
      _username = await _secureStorage.readUsername();
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _errorMessage = null;
    try {
      final token = await _api.login(username, password);
      await _secureStorage.saveSession(token: token, username: username.trim());
      _isLoggedIn = true;
      _username = username.trim();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

   Future<void> logout() async {
    await _secureStorage.clearSession();
    debugPrint('DEBUG logout: token sudah dihapus');
    _isLoggedIn = false;
    _username = null;
    notifyListeners();
  }
}
