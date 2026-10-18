import 'package:flutter/material.dart';
import '../data/local/settings_service.dart';

/// Global State untuk pengaturan. Nilainya disimpan di shared_preferences,
/// jadi tetap ada setelah app ditutup lalu dibuka lagi.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._service);

  final SettingsService _service;

  bool get notificationsEnabled => _service.notificationsEnabled;
  bool get simulateOffline => _service.simulateOffline;

  Future<void> setNotificationsEnabled(bool value) async {
    await _service.setNotificationsEnabled(value);
    notifyListeners();
  }

  Future<void> setSimulateOffline(bool value) async {
    await _service.setSimulateOffline(value);
    notifyListeners();
  }
}
