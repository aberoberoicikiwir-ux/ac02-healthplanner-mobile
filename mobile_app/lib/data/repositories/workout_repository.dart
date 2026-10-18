import '../../models/workout.dart';
import '../local/app_database.dart';
import '../remote/fake_api_service.dart';

/// Repository = penghubung antara API (remote) dan database (local).
/// Pola offline-first: UI SELALU membaca dari database, bukan dari API.
/// API hanya dipakai untuk mengisi/memperbarui database.
class WorkoutRepository {
  WorkoutRepository(this._db, this._api);

  final AppDatabase _db;
  final FakeApiService _api;

  /// Stream dari database -> otomatis update saat data berubah.
  Stream<List<Workout>> watchWorkouts() {
    return _db.watchAllWorkouts().map(
          (rows) => rows.map(_toModel).toList(),
        );
  }

  /// Ambil dari server lalu simpan (cache) ke database.
  /// Kalau gagal (offline), exception dilempar ke provider; data lama tetap ada.
  Future<void> refreshFromServer() async {
    final data = await _api.fetchWorkouts();
    final nowUtcMillis = DateTime.now().toUtc().millisecondsSinceEpoch;

    final rows = data
        .map(
          (json) => WorkoutEntriesCompanion.insert(
            id: json['id'] as String,
            name: json['name'] as String,
            detail: json['detail'] as String,
            benefit: json['benefit'] as String,
            lastFetched: nowUtcMillis,
          ),
        )
        .toList();

    await _db.upsertWorkouts(rows);
  }

  Future<void> setDone(String id, bool value) => _db.setDone(id, value);

  Workout _toModel(WorkoutEntry e) => Workout(
        id: e.id,
        name: e.name,
        detail: e.detail,
        benefit: e.benefit,
        isDone: e.isDone,
        lastFetched: e.lastFetched,
      );
}
