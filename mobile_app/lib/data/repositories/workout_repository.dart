import 'package:drift/drift.dart' show Value;

import '../../models/workout.dart';
import '../local/app_database.dart';
import '../remote/fake_api_service.dart';

/// Repository = penghubung antara API (remote) dan database (local).
/// Pola offline-first: UI SELALU membaca dari database, bukan langsung dari
/// API. Penulisan masuk ke database lokal lebih dulu (synced = false), lalu
/// dikirim ke server saat online.
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

  /// Kirim perubahan lokal yang belum tersinkron, lalu tandai synced = true.
  /// Jaringan dipanggil SEBELUM transaksi dimulai (bukan di dalamnya).
  Future<void> pushPending() async {
    final pending = await _db.getUnsyncedWorkouts();
    if (pending.isEmpty) return;

    await _api.pushWorkouts(
      pending
          .map((e) => {
                'id': e.id,
                'name': e.name,
                'isDone': e.isDone,
                'updatedAt': e.updatedAt,
              })
          .toList(),
    );

    await _db.markSynced(pending);
  }

  /// Ambil dari server lalu simpan (cache) ke database dalam satu transaksi.
  /// Kalau gagal (offline), exception dilempar ke provider; data lama tetap ada.
  Future<void> pullFromServer() async {
    final data = await _api.fetchWorkouts();
    final now = nowUtcMillis();

    final rows = data
        .map(
          (json) => WorkoutEntriesCompanion.insert(
            id: json['id'] as String,
            name: json['name'] as String,
            detail: json['detail'] as String,
            benefit: json['benefit'] as String,
            lastFetched: now,
            updatedAt: Value(now),
            synced: const Value(true),
          ),
        )
        .toList();

    await _db.upsertServerWorkouts(rows);
  }

  Future<void> addWorkout({
    required String id,
    required String name,
    required String detail,
    required String benefit,
  }) =>
      _db.insertWorkout(id: id, name: name, detail: detail, benefit: benefit);

  Future<void> setDone(String id, bool value) => _db.setDone(id, value);

  Future<void> deleteWorkout(String id) => _db.deleteWorkout(id);

  Workout _toModel(WorkoutEntry e) => Workout(
        id: e.id,
        name: e.name,
        detail: e.detail,
        benefit: e.benefit,
        isDone: e.isDone,
        lastFetched: e.lastFetched,
        updatedAt: e.updatedAt,
        synced: e.synced,
      );
}
