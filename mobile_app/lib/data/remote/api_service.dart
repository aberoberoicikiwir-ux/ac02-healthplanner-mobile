import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../local/secure_storage_service.dart';
import '../local/settings_service.dart';

/// Error dari backend (status HTTP + pesan siap tampil).
class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int? statusCode;
  final String message;

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;

  @override
  String toString() => message;
}

class LoginResult {
  const LoginResult({
    required this.token,
    required this.name,
    required this.role,
    this.userId,
  });

  final String token;
  final String name;
  final String role;
  final int? userId;
}

/// Klien REST ke backend Express. Semua panggilan jaringan lewat sini.
class ApiService {
  ApiService(this._settings, this._secureStorage);

  final SettingsService _settings;
  final SecureStorageService _secureStorage;

  /// Dipanggil saat server membalas 401 (token habis/tidak valid).
  void Function()? onUnauthorized;

  static const _timeout = Duration(seconds: 20);

  Uri _uri(String path, [Map<String, String>? query]) {
    var base = _settings.apiBaseUrl.trim();
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    final uri = Uri.parse('$base$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: {...uri.queryParameters, ...query});
  }

  Future<Map<String, String>> _headers({required bool auth}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await _secureStorage.readToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    bool auth = true,
  }) async {
    if (_settings.simulateOffline) {
      throw ApiException(null, 'Mode simulasi offline aktif.');
    }

    final client = http.Client();
    try {
      final request = http.Request(method, _uri(path, query));
      request.headers.addAll(await _headers(auth: auth));
      if (body != null) request.body = jsonEncode(body);

      final streamed = await client.send(request).timeout(_timeout);
      return await http.Response.fromStream(streamed).timeout(_timeout);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException(null, 'Server tidak merespons. Coba lagi.');
    } catch (_) {
      throw ApiException(
        null,
        'Tidak bisa terhubung ke server. Periksa alamat server dan koneksi.',
      );
    } finally {
      client.close();
    }
  }

  dynamic _decode(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return const {};
  }

  void _throwIfError(
    http.Response response,
    dynamic decoded, {
    required bool auth,
  }) {
    final code = response.statusCode;
    if (code >= 200 && code < 300) return;
    if (code == 401 && auth) onUnauthorized?.call();

    final map = _asMap(decoded);
    final message =
        map['message']?.toString() ?? 'Terjadi kesalahan pada server ($code).';
    throw ApiException(code, message);
  }

  Future<Map<String, dynamic>> _requestMap(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    bool auth = true,
  }) async {
    final response = await _send(
      method,
      path,
      body: body,
      query: query,
      auth: auth,
    );
    final decoded = _decode(response.body);
    _throwIfError(response, decoded, auth: auth);
    return _asMap(decoded);
  }

  Future<List<Map<String, dynamic>>> _requestList(
    String method,
    String path, {
    Map<String, String>? query,
  }) async {
    final response = await _send(method, path, query: query);
    final decoded = _decode(response.body);
    _throwIfError(response, decoded, auth: true);
    if (decoded is List) {
      return decoded.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }

  // ---------------------------------------------------------------- auth
  Future<LoginResult> login(String username, String password) async {
    final data = await _requestMap(
      'POST',
      '/auth/login',
      body: {'username': username.trim(), 'password': password},
      auth: false,
    );

    final token = data['token']?.toString();
    final user = data['user'];
    final map = _asMap(user);
    final role = map['role']?.toString() ?? '';
    final name = map['name']?.toString() ?? username.trim();
    final userId = (map['user_id'] as num?)?.toInt();

    if (token == null || token.isEmpty) {
      throw ApiException(null, 'Respons login tidak valid.');
    }
    return LoginResult(token: token, name: name, role: role, userId: userId);
  }

  Future<void> logout() async {
    // Server tidak menyimpan sesi; ini hanya formalitas agar kontrak terpenuhi.
    try {
      await _requestMap('POST', '/auth/logout');
    } on ApiException {
      // Abaikan: logout lokal tetap harus berhasil.
    }
  }

  // -------------------------------------------------------------- profile
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final data = await _requestMap('GET', '/clients/me/profile');
      return data.isEmpty ? null : data;
    } on ApiException catch (e) {
      if (e.isNotFound) return null;
      rethrow;
    }
  }

  Future<void> createProfile(Map<String, dynamic> body) =>
      _requestMap('POST', '/clients/me/profile', body: body);

  Future<void> updateProfile(Map<String, dynamic> body) =>
      _requestMap('PATCH', '/clients/me/profile', body: body);

  Future<void> choosePt(String ptUsername) => _requestMap(
    'POST',
    '/clients/me/pt',
    body: {'pt_username': ptUsername.trim()},
  );

  // -------------------------------------------------------------- workout
  Future<Map<String, dynamic>?> getCurrentWorkoutPlan() async {
    try {
      final data = await _requestMap(
        'GET',
        '/clients/me/workout-plans/current',
      );
      return data.isEmpty ? null : data;
    } on ApiException catch (e) {
      if (e.isNotFound) return null;
      rethrow;
    }
  }

  Future<void> patchWorkoutItem(String itemId, bool isCompleted) => _requestMap(
    'PATCH',
    '/workout-plan-items/$itemId',
    body: {'is_completed': isCompleted},
  );

  // ----------------------------------------------------------------- meal
  Future<Map<String, dynamic>?> getCurrentMealPlan() async {
    try {
      final data = await _requestMap('GET', '/clients/me/meal-plans/current');
      return data.isEmpty ? null : data;
    } on ApiException catch (e) {
      if (e.isNotFound) return null;
      rethrow;
    }
  }

  Future<void> patchMealItem(String itemId, bool isCompleted) => _requestMap(
    'PATCH',
    '/meal-plan-items/$itemId',
    body: {'is_completed': isCompleted},
  );

  // --------------------------------------------------- target & daily log
  Future<Map<String, dynamic>?> getCurrentTarget() async {
    final data = await _requestMap('GET', '/clients/me/targets/current');
    return data.isEmpty ? null : data;
  }

  Future<Map<String, dynamic>?> getTodayLog() async {
    final data = await _requestMap('GET', '/clients/me/daily-logs/today');
    return data.isEmpty ? null : data;
  }

  Future<List<Map<String, dynamic>>> getLogHistory({
    required String from,
    required String to,
  }) => _requestList(
    'GET',
    '/clients/me/daily-logs',
    query: {'from': from, 'to': to},
  );

  Future<void> putTodayLog({
    int? steps,
    double? waterLiters,
    double? weightKg,
  }) {
    final body = <String, dynamic>{};
    if (steps != null) body['steps'] = steps;
    if (waterLiters != null) body['water_liters'] = waterLiters;
    if (weightKg != null) body['weight_kg'] = weightKg;
    if (body.isEmpty) return Future.value();
    return _requestMap('PUT', '/clients/me/daily-logs/today', body: body);
  }
}
