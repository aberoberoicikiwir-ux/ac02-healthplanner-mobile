import 'package:flutter/material.dart';

import '../data/local/secure_storage_service.dart';
import '../data/remote/api_service.dart';

/// Global State untuk status login. Token disimpan di secure storage.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._api, this._secureStorage) {
    _api.onUnauthorized = _handleUnauthorized;
  }

  final ApiService _api;
  final SecureStorageService _secureStorage;

  /// Dipanggil saat logout agar cache lokal akun lama dibersihkan.
  Future<void> Function()? onLoggedOut;

  /// Dipanggil sebelum sesi baru dimulai agar tidak ada sisa akun sebelumnya.
  Future<void> Function()? onSessionStart;

  bool _isLoggedIn = false;
  String? _name;
  String? _errorMessage;
  bool _needsCacheReset = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get displayName => _name;

  /// True bila sesi lama tidak punya penanda pemilik cache (versi aplikasi
  /// sebelum integrasi backend). Cache lokal harus dibersihkan.
  bool get needsCacheReset => _needsCacheReset;

  /// Nama lama agar layar yang sudah ada tetap kompatibel.
  String? get username => _name;
  String? get errorMessage => _errorMessage;

  /// Dipanggil sekali saat app dibuka: kalau token masih ada, anggap login.
  Future<void> restoreSession() async {
    final token = await _secureStorage.readToken();
    if (token != null && token.isNotEmpty) {
      _isLoggedIn = true;
      _name =
          await _secureStorage.readName() ??
          await _secureStorage.readUsername();
      final userId = await _secureStorage.readUserId();
      if (userId == null) _needsCacheReset = true;
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _errorMessage = null;
    try {
      final result = await _api.login(username, password);
      if (result.role != 'klien') {
        _errorMessage =
            'Akun ini bukan akun klien. Aplikasi ini khusus untuk klien.';
        notifyListeners();
        return false;
      }
      await onSessionStart?.call();
      await _secureStorage.saveSession(
        token: result.token,
        name: result.name,
        username: username.trim(),
        userId: result.userId,
      );
      _isLoggedIn = true;
      _name = result.name;
      _needsCacheReset = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {
      // Logout lokal tetap harus berhasil walau server tidak terjangkau.
    }
    await _secureStorage.clearSession();
    _isLoggedIn = false;
    _name = null;
    _errorMessage = null;
    notifyListeners();
    await onLoggedOut?.call();
  }

  /// 401 dari endpoint mana pun -> sesi dianggap habis.
  void _handleUnauthorized() {
    if (!_isLoggedIn) return;
    _isLoggedIn = false;
    _name = null;
    _errorMessage = 'Sesi berakhir. Silakan login lagi.';
    notifyListeners();
    _secureStorage.clearSession();
    onLoggedOut?.call();
  }
}
