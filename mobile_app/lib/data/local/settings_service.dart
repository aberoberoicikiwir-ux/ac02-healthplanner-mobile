import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan PENGATURAN (kecil & tidak sensitif) -> shared_preferences.
/// JANGAN simpan token/password di sini.
class SettingsService {
  SettingsService(this._prefs);

  final SharedPreferences _prefs;

  static const _notifKey = 'notifications_enabled';
  static const _offlineKey = 'simulate_offline';
  static const _baseUrlKey = 'api_base_url';

  bool get notificationsEnabled => _prefs.getBool(_notifKey) ?? true;
  Future<bool> setNotificationsEnabled(bool value) =>
      _prefs.setBool(_notifKey, value);

  /// Hanya untuk demo: memaksa API gagal supaya terlihat app tetap
  /// menampilkan data dari database lokal.
  bool get simulateOffline => _prefs.getBool(_offlineKey) ?? false;
  Future<bool> setSimulateOffline(bool value) =>
      _prefs.setBool(_offlineKey, value);

  /// Alamat backend. Emulator Android memakai 10.0.2.2 untuk mencapai laptop.
  String get defaultApiBaseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  String get apiBaseUrl {
    final saved = _prefs.getString(_baseUrlKey);
    if (saved == null || saved.trim().isEmpty) return defaultApiBaseUrl;
    return saved.trim();
  }

  Future<bool> setApiBaseUrl(String value) =>
      _prefs.setString(_baseUrlKey, value.trim());
}
