import 'package:flutter/foundation.dart';
import '../local/settings_service.dart';

/// API TIRUAN. Alurnya sama seperti API asli (ada delay, bisa gagal),
/// jadi nanti tinggal diganti dengan pemanggilan HTTP ke backend Express.
class FakeApiService {
  FakeApiService(this._settings);

  final SettingsService _settings;

  Future<void> _simulateNetwork() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (_settings.simulateOffline) {
      throw Exception('Tidak ada koneksi internet');
    }
  }

  /// Mengembalikan token palsu. Username & password apa saja diterima
  /// selama tidak kosong (backend asli belum ada).
  Future<String> login(String username, String password) async {
    await _simulateNetwork();
    if (username.trim().isEmpty || password.isEmpty) {
      throw Exception('Username dan password wajib diisi');
    }
    return 'fake-jwt-token-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<List<Map<String, dynamic>>> fetchWorkouts() async {
    await _simulateNetwork();
    return [
      {
        'id': '1',
        'name': 'Push Up',
        'detail': '3 sets x 15 reps',
        'benefit': 'This exercise works the chest, shoulders, and triceps. '
            'Keep your body straight from head to heels throughout the movement.',
      },
      {
        'id': '2',
        'name': 'Squat',
        'detail': '3 sets x 20 reps',
        'benefit': 'This exercise works the thighs and glutes. '
            'Keep your knees behind your toes when bending.',
      },
      {
        'id': '3',
        'name': 'Plank',
        'detail': '3 sets x 45 sec',
        'benefit': 'This exercise strengthens the core. '
            'Keep your back flat, avoid letting your hips sag or rise.',
      },
    ];
  }

  /// Mengirim perubahan lokal yang belum tersinkron ke server.
  /// Di backend asli ini akan menjadi POST /workouts/sync dengan body [changes].
  Future<void> pushWorkouts(List<Map<String, dynamic>> changes) async {
    await _simulateNetwork();
    debugPrint('SYNC: server menerima ${changes.length} perubahan -> $changes');
  }
}
