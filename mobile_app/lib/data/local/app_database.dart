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

  /// Schema v3: hari dari rencana server, mis. "mon". Null untuk latihan lokal.
  TextColumn get dayOfWeek => text().nullable()();

  /// Schema v3: kategori latihan, mis. "strength", "cardio", "flexibility".
  TextColumn get category => text().nullable()();

  BoolColumn get isDone => boolean().withDefault(const Constant(false))();

  /// Penanda cache: kapan data ini terakhir diambil dari server (UTC millis).
  IntColumn get lastFetched => integer()();

  /// Schema v2: kapan baris ini terakhir diubah di perangkat (UTC millis).
  IntColumn get updatedAt => integer().withDefault(const Constant(0))();

  /// Schema v2: false = ada perubahan lokal yang belum dikirim ke server.
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MealEntry')
class MealEntries extends Table {
  TextColumn get id => text()();
  TextColumn get dayOfWeek => text().nullable()();
  TextColumn get mealType => text()();
  TextColumn get foodName => text()();
  IntColumn get calories => integer().nullable()();
  RealColumn get proteinG => real().nullable()();
  RealColumn get carbsG => real().nullable()();
  RealColumn get fatG => real().nullable()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  IntColumn get lastFetched => integer()();
  IntColumn get updatedAt => integer().withDefault(const Constant(0))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TargetEntry')
class TargetEntries extends Table {
  TextColumn get id => text()(); // selalu 'current'
  TextColumn get weekStartDate => text().nullable()();
  IntColumn get targetSteps => integer().nullable()();
  RealColumn get targetWaterLiters => real().nullable()();
  IntColumn get targetCalories => integer().nullable()();
  TextColumn get source => text().nullable()();
  IntColumn get lastFetched => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DailyLogEntry')
class DailyLogEntries extends Table {
  TextColumn get logDate => text()(); // "YYYY-MM-DD"
  RealColumn get weightKg => real().nullable()();
  IntColumn get steps => integer().nullable()();
  RealColumn get waterLiters => real().nullable()();
  RealColumn get caloriesBurned => real().nullable()();
  IntColumn get lastFetched => integer()();
  IntColumn get updatedAt => integer().withDefault(const Constant(0))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {logDate};
}

@DataClassName('ClientProfileEntry')
class ClientProfileEntries extends Table {
  TextColumn get id => text()(); // selalu 'me'
  TextColumn get payload => text()(); // JSON profil dari server
  IntColumn get lastFetched => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('NotificationEntry')
class NotificationEntries extends Table {
  IntColumn get id => integer()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get message => text()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CoachMessageEntry')
class CoachMessages extends Table {
  IntColumn get id => integer()();
  TextColumn get role => text()();
  TextColumn get content => text()();
  TextColumn get category => text().nullable()();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    WorkoutEntries,
    MealEntries,
    TargetEntries,
    DailyLogEntries,
    ClientProfileEntries,
    NotificationEntries,
    CoachMessages,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'healthmaxxing_db'));

  @override
  int get schemaVersion => 4;

  /// MIGRASI: v1 -> v2 -> v3 tanpa menghapus data pengguna.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(workoutEntries, workoutEntries.updatedAt);
        await m.addColumn(workoutEntries, workoutEntries.synced);
        await customStatement('UPDATE workout_entries SET synced = 1;');
      }
      if (from < 3) {
        await m.addColumn(workoutEntries, workoutEntries.dayOfWeek);
        await m.addColumn(workoutEntries, workoutEntries.category);
        await m.createTable(mealEntries);
        await m.createTable(targetEntries);
        await m.createTable(dailyLogEntries);
        await m.createTable(clientProfileEntries);
      }
      if (from < 4) {
        await m.createTable(notificationEntries);
        await m.createTable(coachMessages);
      }
    },
  );

  // ================================================================ workout
  Stream<List<WorkoutEntry>> watchAllWorkouts() {
    return (select(
      workoutEntries,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).watch();
  }

  /// Data server: baris baru ditambahkan; baris lama hanya ditimpa kolom
  /// milik server. Status selesai lokal yang belum terkirim (synced=false)
  /// tidak ditimpa.
  Future<void> upsertServerWorkouts(List<WorkoutEntriesCompanion> rows) {
    return transaction(() async {
      for (final row in rows) {
        final id = row.id.value;
        final existing = await (select(
          workoutEntries,
        )..where((t) => t.id.equals(id))).getSingleOrNull();

        if (existing == null) {
          await into(workoutEntries).insert(row);
        } else {
          final keepLocalDone = !existing.synced;
          await (update(workoutEntries)..where((t) => t.id.equals(id))).write(
            WorkoutEntriesCompanion(
              name: row.name,
              detail: row.detail,
              benefit: row.benefit,
              dayOfWeek: row.dayOfWeek,
              category: row.category,
              lastFetched: row.lastFetched,
              isDone: keepLocalDone ? const Value.absent() : row.isDone,
            ),
          );
        }
      }
    });
  }

  /// Hapus baris server yang tidak ada lagi di respons terbaru.
  /// Baris "local-" (buatan pengguna) selalu dipertahankan.
  Future<void> deleteStaleServerWorkouts(Set<String> keepIds) async {
    await (delete(workoutEntries)..where((t) {
          Expression<bool> predicate = t.id.like('local-%').not();
          if (keepIds.isNotEmpty) {
            predicate = predicate & t.id.isNotIn(keepIds);
          }
          return predicate;
        }))
        .go();
  }

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

  Future<void> setDone(String id, bool value) {
    return (update(workoutEntries)..where((t) => t.id.equals(id))).write(
      WorkoutEntriesCompanion(
        isDone: Value(value),
        synced: const Value(false),
        updatedAt: Value(nowUtcMillis()),
      ),
    );
  }

  Future<void> deleteWorkout(String id) {
    return (delete(workoutEntries)..where((t) => t.id.equals(id))).go();
  }

  Future<List<WorkoutEntry>> getUnsyncedWorkouts() {
    return (select(workoutEntries)..where((t) => t.synced.equals(false))).get();
  }

  Future<void> markSynced(List<WorkoutEntry> sent) {
    return transaction(() async {
      for (final row in sent) {
        await (update(workoutEntries)..where(
              (t) => t.id.equals(row.id) & t.updatedAt.equals(row.updatedAt),
            ))
            .write(const WorkoutEntriesCompanion(synced: Value(true)));
      }
    });
  }

  // =================================================================== meal
  Stream<List<MealEntry>> watchAllMeals() {
    return (select(mealEntries)..orderBy([
          (t) => OrderingTerm.asc(t.dayOfWeek),
          (t) => OrderingTerm.asc(t.mealType),
          (t) => OrderingTerm.asc(t.id),
        ]))
        .watch();
  }

  Future<void> upsertServerMeals(List<MealEntriesCompanion> rows) {
    return transaction(() async {
      for (final row in rows) {
        final id = row.id.value;
        final existing = await (select(
          mealEntries,
        )..where((t) => t.id.equals(id))).getSingleOrNull();

        if (existing == null) {
          await into(mealEntries).insert(row);
        } else {
          final keepLocalDone = !existing.synced;
          await (update(mealEntries)..where((t) => t.id.equals(id))).write(
            MealEntriesCompanion(
              dayOfWeek: row.dayOfWeek,
              mealType: row.mealType,
              foodName: row.foodName,
              calories: row.calories,
              proteinG: row.proteinG,
              carbsG: row.carbsG,
              fatG: row.fatG,
              lastFetched: row.lastFetched,
              isDone: keepLocalDone ? const Value.absent() : row.isDone,
            ),
          );
        }
      }
    });
  }

  Future<void> deleteStaleServerMeals(Set<String> keepIds) async {
    if (keepIds.isEmpty) {
      await delete(mealEntries).go();
      return;
    }
    await (delete(mealEntries)..where((t) => t.id.isNotIn(keepIds))).go();
  }

  Future<void> setMealDone(String id, bool value) {
    return (update(mealEntries)..where((t) => t.id.equals(id))).write(
      MealEntriesCompanion(
        isDone: Value(value),
        synced: const Value(false),
        updatedAt: Value(nowUtcMillis()),
      ),
    );
  }

  Future<void> deleteMeal(String id) {
    return (delete(mealEntries)..where((t) => t.id.equals(id))).go();
  }

  Future<List<MealEntry>> getUnsyncedMeals() {
    return (select(mealEntries)..where((t) => t.synced.equals(false))).get();
  }

  Future<void> markMealsSynced(List<MealEntry> sent) {
    return transaction(() async {
      for (final row in sent) {
        await (update(mealEntries)..where(
              (t) => t.id.equals(row.id) & t.updatedAt.equals(row.updatedAt),
            ))
            .write(const MealEntriesCompanion(synced: Value(true)));
      }
    });
  }

  // ================================================================= target
  Future<void> upsertTarget(TargetEntriesCompanion row) =>
      into(targetEntries).insertOnConflictUpdate(row);

  Future<TargetEntry?> getTarget() {
    return (select(
      targetEntries,
    )..where((t) => t.id.equals('current'))).getSingleOrNull();
  }

  // ================================================ daily logs & profile
  Future<void> upsertServerDailyLogs(List<DailyLogEntriesCompanion> rows) {
    return transaction(() async {
      for (final row in rows) {
        final date = row.logDate.value;
        final existing = await (select(
          dailyLogEntries,
        )..where((t) => t.logDate.equals(date))).getSingleOrNull();

        if (existing == null) {
          await into(dailyLogEntries).insert(row);
        } else if (existing.synced) {
          await (update(
            dailyLogEntries,
          )..where((t) => t.logDate.equals(date))).write(
            DailyLogEntriesCompanion(
              weightKg: row.weightKg,
              steps: row.steps,
              waterLiters: row.waterLiters,
              caloriesBurned: row.caloriesBurned,
              lastFetched: row.lastFetched,
            ),
          );
        }
      }
    });
  }

  Future<void> setLocalTodayLog({
    required String logDate,
    int? steps,
    double? waterLiters,
    double? weightKg,
  }) async {
    final existing = await (select(
      dailyLogEntries,
    )..where((t) => t.logDate.equals(logDate))).getSingleOrNull();

    if (existing == null) {
      await into(dailyLogEntries).insert(
        DailyLogEntriesCompanion.insert(
          logDate: logDate,
          lastFetched: 0,
          steps: Value(steps),
          waterLiters: Value(waterLiters),
          weightKg: Value(weightKg),
          updatedAt: Value(nowUtcMillis()),
          synced: const Value(false),
        ),
      );
      return;
    }

    await (update(
      dailyLogEntries,
    )..where((t) => t.logDate.equals(logDate))).write(
      DailyLogEntriesCompanion(
        steps: steps == null ? const Value.absent() : Value(steps),
        waterLiters: waterLiters == null
            ? const Value.absent()
            : Value(waterLiters),
        weightKg: weightKg == null ? const Value.absent() : Value(weightKg),
        updatedAt: Value(nowUtcMillis()),
        synced: const Value(false),
      ),
    );
  }

  Future<DailyLogEntry?> getDailyLog(String logDate) {
    return (select(
      dailyLogEntries,
    )..where((t) => t.logDate.equals(logDate))).getSingleOrNull();
  }

  Future<List<DailyLogEntry>> getDailyLogsSince(String fromDate) {
    return (select(dailyLogEntries)
          ..where((t) => t.logDate.isBiggerOrEqualValue(fromDate))
          ..orderBy([(t) => OrderingTerm.asc(t.logDate)]))
        .get();
  }

  Future<List<DailyLogEntry>> getUnsyncedDailyLogs() {
    return (select(
      dailyLogEntries,
    )..where((t) => t.synced.equals(false))).get();
  }

  Future<void> markDailyLogsSynced(List<DailyLogEntry> sent) {
    return transaction(() async {
      for (final row in sent) {
        await (update(dailyLogEntries)..where(
              (t) =>
                  t.logDate.equals(row.logDate) &
                  t.updatedAt.equals(row.updatedAt),
            ))
            .write(const DailyLogEntriesCompanion(synced: Value(true)));
      }
    });
  }

  /// Hapus log tersinkron yang tidak lagi ada di respons server (mis. sisa
  /// akun lain). Log lokal yang belum terkirim tetap dipertahankan.
  Future<void> deleteStaleSyncedDailyLogs(Set<String> keepDates) async {
    await (delete(dailyLogEntries)..where((t) {
          Expression<bool> predicate = t.synced.equals(true);
          if (keepDates.isNotEmpty) {
            predicate = predicate & t.logDate.isNotIn(keepDates);
          }
          return predicate;
        }))
        .go();
  }

  Future<void> upsertClientProfile(String payload) {
    return into(clientProfileEntries).insertOnConflictUpdate(
      ClientProfileEntriesCompanion.insert(
        id: 'me',
        payload: payload,
        lastFetched: nowUtcMillis(),
      ),
    );
  }

  Future<String?> getClientProfilePayload() async {
    final row = await (select(
      clientProfileEntries,
    )..where((t) => t.id.equals('me'))).getSingleOrNull();
    return row?.payload;
  }

  // ======================================================== notifikasi & chat
  Stream<List<NotificationEntry>> watchNotifications() {
    return (select(
      notificationEntries,
    )..orderBy([(t) => OrderingTerm.desc(t.id)])).watch();
  }

  Future<void> upsertNotifications(List<NotificationEntriesCompanion> rows) {
    return transaction(() async {
      for (final row in rows) {
        await into(notificationEntries).insertOnConflictUpdate(row);
      }
    });
  }

  Future<void> deleteStaleNotifications(Set<int> keepIds) async {
    if (keepIds.isEmpty) {
      await delete(notificationEntries).go();
      return;
    }
    await (delete(
      notificationEntries,
    )..where((t) => t.id.isNotIn(keepIds))).go();
  }

  Future<void> markNotificationReadLocal(int id) {
    return (update(notificationEntries)..where((t) => t.id.equals(id))).write(
      const NotificationEntriesCompanion(isRead: Value(true)),
    );
  }

  Stream<List<CoachMessageEntry>> watchCoachMessages() {
    return (select(
      coachMessages,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).watch();
  }

  Future<void> upsertCoachMessages(List<CoachMessagesCompanion> rows) {
    return transaction(() async {
      for (final row in rows) {
        await into(coachMessages).insertOnConflictUpdate(row);
      }
    });
  }

  Future<void> clearCoachMessages() => delete(coachMessages).go();

  /// Bersihkan semua data pengguna saat logout agar akun berikutnya tidak
  /// melihat cache akun sebelumnya.
  Future<void> clearUserData() async {
    await transaction(() async {
      await delete(workoutEntries).go();
      await delete(mealEntries).go();
      await delete(targetEntries).go();
      await delete(dailyLogEntries).go();
      await delete(clientProfileEntries).go();
      await delete(notificationEntries).go();
      await delete(coachMessages).go();
    });
  }
}
