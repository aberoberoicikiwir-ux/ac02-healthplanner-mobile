import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan PENGATURAN (kecil & tidak sensitif) -> shared_preferences.
/// JANGAN simpan token/password di sini.
class SettingsService {
  SettingsService(this._prefs);

  final SharedPreferences _prefs;

  static const _notifKey = 'notifications_enabled';
  static const _offlineKey = 'simulate_offline';

  bool get notificationsEnabled => _prefs.getBool(_notifKey) ?? true;
  Future<bool> setNotificationsEnabled(bool value) =>
      _prefs.setBool(_notifKey, value);

  /// Hanya untuk demo: memaksa "API" gagal supaya terlihat app tetap
  /// menampilkan data dari database lokal.
  bool get simulateOffline => _prefs.getBool(_offlineKey) ?? false;
  Future<bool> setSimulateOffline(bool value) =>
      _prefs.setBool(_offlineKey, value);
}
