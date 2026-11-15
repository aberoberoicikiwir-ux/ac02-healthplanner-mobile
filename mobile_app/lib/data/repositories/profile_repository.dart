import 'dart:convert';

import '../local/app_database.dart';
import '../remote/api_service.dart';

class ProfileRepository {
  ProfileRepository(this._db, this._api);

  final AppDatabase _db;
  final ApiService _api;

  /// Ambil profil dari server dan simpan salinannya untuk mode offline.
  Future<Map<String, dynamic>?> fetchAndCache() async {
    final data = await _api.getProfile();
    if (data != null) {
      await _db.upsertClientProfile(jsonEncode(data));
    }
    return data;
  }

  Future<Map<String, dynamic>?> readCache() async {
    final payload = await _db.getClientProfilePayload();
    if (payload == null) return null;
    try {
      final decoded = jsonDecode(payload);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> createProfile(Map<String, dynamic> body) =>
      _api.createProfile(body);

  Future<void> updateProfile(Map<String, dynamic> body) =>
      _api.updateProfile(body);

  Future<void> choosePt(String ptUsername) => _api.choosePt(ptUsername);
}
