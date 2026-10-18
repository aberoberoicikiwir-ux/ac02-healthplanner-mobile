import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// File ini akan "dilengkapi" otomatis oleh build_runner -> app_database.g.dart
part 'app_database.g.dart';

/// Waktu sekarang dalam UTC milliseconds. Simpan selalu dalam UTC,
/// ubah ke waktu lokal hanya saat ditampilkan.
int nowUtcMillis() => DateTime.now().toUtc().millisecondsSinceEpoch;

/// Tabel latihan (data terstruktur). Nama tabel di SQLite: workout_entries.
@DataClassName('WorkoutEntry')
class WorkoutEntries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get detail => text()();
  TextColumn get benefit => text()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();

  /// Penanda cache: kapan data ini terakhir diambil dari server (UTC millis).
  IntColumn get lastFetched => integer()();

  /// Schema v2: kapan baris ini terakhir diubah di perangkat (UTC millis).
  IntColumn get updatedAt => integer().withDefault(const Constant(0))();

  /// Schema v2: false = ada perubahan lokal yang belum dikirim ke server.
  /// Setiap penulisan lokal dimulai dengan synced = false (pola offline-first).
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [WorkoutEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'healthmaxxing_db'));

  /// Naik dari 1 ke 2 karena ada kolom baru (updatedAt dan synced).
  @override
  int get schemaVersion => 2;

  /// MIGRASI: mengubah database versi lama ke versi baru tanpa menghapus
  /// data pengguna. Pengguna yang masih di v1 mendapat dua kolom baru.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(workoutEntries, workoutEntries.updatedAt);
            await m.addColumn(workoutEntries, workoutEntries.synced);
            // Baris lama berasal dari server, jadi dianggap sudah tersinkron.
            await customStatement('UPDATE workout_entries SET synced = 1;');
          }
        },
      );

  /// STREAM REAKTIF: setiap ada perubahan di tabel, stream ini otomatis
  /// mengirim daftar terbaru, sehingga UI ikut update tanpa dipanggil manual.
  Stream<List<WorkoutEntry>> watchAllWorkouts() {
    return (select(workoutEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .watch();
  }

  /// DATABASE TRANSACTION (data dari server): semua baris ditulis sekaligus
  /// (atomic). Satu baris gagal -> semua dibatalkan (rollback).
  ///
  /// Kalau id sudah ada, HANYA kolom milik server yang diperbarui. isDone,
  /// synced, dan updatedAt (milik pengguna) tidak ditimpa, jadi perubahan
  /// lokal yang belum terkirim tidak hilang.
  Future<void> upsertServerWorkouts(List<WorkoutEntriesCompanion> rows) {
    return transaction(() async {
      for (final row in rows) {
        await into(workoutEntries).insert(
          row,
          onConflict: DoUpdate(
            (_) => WorkoutEntriesCompanion(
              name: row.name,
              detail: row.detail,
              benefit: row.benefit,
              lastFetched: row.lastFetched,
            ),
          ),
        );
      }
    });
  }

  /// CREATE: latihan baru dari pengguna. Dimulai dengan synced = false.
  Future<void> insertWorkout({
    required String id,
    required String name,
    required String detail,
    required String benefit,
  }) {
    return into(workoutEntries).insert(
      WorkoutEntriesCompanion.insert(
        id: id,
        name: name,
        detail: detail,
        benefit: benefit,
        lastFetched: 0,
        updatedAt: Value(nowUtcMillis()),
        synced: const Value(false),
      ),
    );
  }

  /// UPDATE: tandai selesai. Perubahan lokal -> synced = false.
  Future<void> setDone(String id, bool value) {
    return (update(workoutEntries)..where((t) => t.id.equals(id))).write(
      WorkoutEntriesCompanion(
        isDone: Value(value),
        synced: const Value(false),
        updatedAt: Value(nowUtcMillis()),
      ),
    );
  }

  /// DELETE: hapus satu latihan.
  Future<void> deleteWorkout(String id) {
    return (delete(workoutEntries)..where((t) => t.id.equals(id))).go();
  }

  /// Baris yang punya perubahan lokal dan belum dikirim ke server.
  Future<List<WorkoutEntry>> getUnsyncedWorkouts() {
    return (select(workoutEntries)..where((t) => t.synced.equals(false)))
        .get();
  }

  /// DATABASE TRANSACTION (setelah sinkron): tandai baris sebagai tersinkron
  /// dalam satu transaksi. Syarat updatedAt harus sama dengan yang dikirim,
  /// jadi kalau pengguna mengubah baris saat pengiriman berlangsung,
  /// perubahan baru itu tetap berstatus belum tersinkron.
  Future<void> markSynced(List<WorkoutEntry> sent) {
    return transaction(() async {
      for (final row in sent) {
        await (update(workoutEntries)
              ..where((t) =>
                  t.id.equals(row.id) & t.updatedAt.equals(row.updatedAt)))
            .write(const WorkoutEntriesCompanion(synced: Value(true)));
      }
    });
  }
}
