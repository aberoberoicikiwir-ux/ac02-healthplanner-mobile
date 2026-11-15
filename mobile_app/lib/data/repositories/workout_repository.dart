import 'package:drift/drift.dart' show Value;

import '../../models/workout.dart';
import '../local/app_database.dart';
import '../remote/api_service.dart';
import '../../utils/formatters.dart';

/// Repository = penghubung antara API (remote) dan database (local).
/// Pola offline-first: UI SELALU membaca dari database, bukan langsung dari
/// API. Penulisan masuk ke database lokal lebih dulu (synced = false), lalu
/// dikirim ke server saat online.
class WorkoutRepository {
  WorkoutRepository(this._db, this._api);

  final AppDatabase _db;
  final ApiService _api;

  Stream<List<Workout>> watchWorkouts() {
    return _db.watchAllWorkouts().map((rows) => rows.map(_toModel).toList());
  }

  /// Kirim perubahan lokal item server. Latihan buatan pengguna ("local-")
  /// tidak pernah dikirim karena endpoint-nya belum ada.
  Future<void> pushPending() async {
    final pending = await _db.getUnsyncedWorkouts();
    final sent = <WorkoutEntry>[];

    for (final row in pending) {
      if (row.id.startsWith('local-')) continue;
      try {
        await _api.patchWorkoutItem(row.id, row.isDone);
        sent.add(row);
      } on ApiException catch (e) {
        if (e.isNotFound) {
          // Item sudah tidak ada di rencana server -> hapus cache lokalnya.
          await _db.deleteWorkout(row.id);
        } else {
          rethrow;
        }
      }
    }

    if (sent.isNotEmpty) await _db.markSynced(sent);
  }

  /// Ambil rencana terbaru dari server lalu simpan (cache) ke database.
  /// 404 = belum ada rencana -> daftar kosong (empty state), bukan error.
  Future<void> pullFromServer() async {
    final plan = await _api.getCurrentWorkoutPlan();
    final rawItems = plan?['items'];
    final items = rawItems is List ? rawItems : const [];
    final now = nowUtcMillis();

    final rows = <WorkoutEntriesCompanion>[];
    for (final raw in items) {
      if (raw is! Map<String, dynamic>) continue;
      final id = raw['item_id']?.toString();
      final name = raw['exercise_name']?.toString();
      if (id == null || name == null) continue;

      final category = raw['category']?.toString();
      final sets = (raw['sets'] as num?)?.toInt();
      final reps = (raw['reps'] as num?)?.toInt();

      rows.add(
        WorkoutEntriesCompanion.insert(
          id: id,
          name: name,
          detail: workoutDetail(sets: sets, reps: reps, category: category),
          benefit: '',
          dayOfWeek: Value(raw['day_of_week']?.toString()),
          category: Value(category),
          isDone: Value(raw['is_completed'] == true),
          lastFetched: now,
          updatedAt: Value(now),
          synced: const Value(true),
        ),
      );
    }

    await _db.upsertServerWorkouts(rows);
    await _db.deleteStaleServerWorkouts(rows.map((r) => r.id.value).toSet());
  }

  Future<void> addWorkout({
    required String id,
    required String name,
    required String detail,
    required String benefit,
  }) => _db.insertWorkout(id: id, name: name, detail: detail, benefit: benefit);

  Future<void> setDone(String id, bool value) => _db.setDone(id, value);

  Future<void> deleteWorkout(String id) => _db.deleteWorkout(id);

  Workout _toModel(WorkoutEntry e) => Workout(
    id: e.id,
    name: e.name,
    detail: e.detail,
    benefit: e.benefit,
    dayOfWeek: e.dayOfWeek,
    category: e.category,
    isDone: e.isDone,
    lastFetched: e.lastFetched,
    updatedAt: e.updatedAt,
    synced: e.synced,
  );
}
