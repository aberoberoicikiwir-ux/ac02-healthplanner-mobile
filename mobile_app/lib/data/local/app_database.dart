import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// File ini akan "dilengkapi" otomatis oleh build_runner -> app_database.g.dart
part 'app_database.g.dart';

/// Tabel latihan (data terstruktur). Nama tabel di SQLite: workout_entries.
@DataClassName('WorkoutEntry')
class WorkoutEntries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get detail => text()();
  TextColumn get benefit => text()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();

  /// Penanda cache: kapan data ini terakhir diambil dari server.
  /// Disimpan dalam UTC milliseconds (DateTime.now().toUtc().millisecondsSinceEpoch).
  IntColumn get lastFetched => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [WorkoutEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'healthmaxxing_db'));

  @override
  int get schemaVersion => 1;

  /// STREAM REAKTIF: setiap ada perubahan di tabel, stream ini otomatis
  /// mengirim daftar terbaru, sehingga UI ikut update tanpa dipanggil manual.
  Stream<List<WorkoutEntry>> watchAllWorkouts() {
    return (select(workoutEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .watch();
  }

  /// DATABASE TRANSACTION: semua baris ditulis sekaligus (atomic).
  /// Kalau ada satu baris yang gagal, SEMUA perubahan dibatalkan (rollback),
  /// jadi tabel tidak pernah berisi data setengah-setengah.
  ///
  /// insertOnConflictUpdate: kalau id sudah ada -> di-update, kalau belum -> insert.
  /// Kolom isDone sengaja tidak diisi dari server, jadi progres user tidak tertimpa.
  Future<void> upsertWorkouts(List<WorkoutEntriesCompanion> rows) {
    return transaction(() async {
      for (final row in rows) {
        await into(workoutEntries).insertOnConflictUpdate(row);
      }
    });
  }

  Future<void> setDone(String id, bool value) {
    return (update(workoutEntries)..where((t) => t.id.equals(id)))
        .write(WorkoutEntriesCompanion(isDone: Value(value)));
  }
}
