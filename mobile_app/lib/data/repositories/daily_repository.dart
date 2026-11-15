import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';
import '../remote/api_service.dart';
import '../../utils/formatters.dart';

class DailyRepository {
  DailyRepository(this._db, this._api);

  final AppDatabase _db;
  final ApiService _api;

  Future<void> pullTarget() async {
    final data = await _api.getCurrentTarget();
    final now = nowUtcMillis();
    await _db.upsertTarget(
      TargetEntriesCompanion.insert(
        id: 'current',
        weekStartDate: Value(data?['week_start_date']?.toString()),
        targetSteps: Value((data?['target_steps'] as num?)?.toInt()),
        targetWaterLiters: Value(
          (data?['target_water_liters'] as num?)?.toDouble(),
        ),
        targetCalories: Value((data?['target_calories'] as num?)?.toInt()),
        source: Value(data?['source']?.toString()),
        lastFetched: now,
      ),
    );
  }

  Future<void> pullToday() async {
    final data = await _api.getTodayLog();
    if (data == null) return;
    final date = data['log_date']?.toString();
    if (date == null) return;
    final now = nowUtcMillis();
    await _db.upsertServerDailyLogs([
      DailyLogEntriesCompanion.insert(
        logDate: date,
        weightKg: Value((data['weight_kg'] as num?)?.toDouble()),
        steps: Value((data['steps'] as num?)?.toInt()),
        waterLiters: Value((data['water_liters'] as num?)?.toDouble()),
        caloriesBurned: Value((data['calories_burned'] as num?)?.toDouble()),
        lastFetched: now,
        updatedAt: Value(now),
        synced: const Value(true),
      ),
    ]);
  }

  Future<void> pullHistory({int days = 30}) async {
    final now = DateTime.now();
    final from = now.subtract(Duration(days: days - 1));
    final rows = await _api.getLogHistory(
      from: localDateString(from),
      to: localDateString(now),
    );
    final fetchedAt = nowUtcMillis();
    final companions = <DailyLogEntriesCompanion>[];

    for (final data in rows) {
      final date = data['log_date']?.toString();
      if (date == null) continue;
      companions.add(
        DailyLogEntriesCompanion.insert(
          logDate: date,
          weightKg: Value((data['weight_kg'] as num?)?.toDouble()),
          steps: Value((data['steps'] as num?)?.toInt()),
          waterLiters: Value((data['water_liters'] as num?)?.toDouble()),
          caloriesBurned: Value((data['calories_burned'] as num?)?.toDouble()),
          lastFetched: fetchedAt,
          updatedAt: Value(fetchedAt),
          synced: const Value(true),
        ),
      );
    }

    await _db.upsertServerDailyLogs(companions);
    await _db.deleteStaleSyncedDailyLogs(
      companions.map((c) => c.logDate.value).toSet(),
    );
  }

  Future<void> pushPending() async {
    final pending = await _db.getUnsyncedDailyLogs();
    final sent = <DailyLogEntry>[];

    for (final row in pending) {
      await _api.putTodayLog(
        steps: row.steps,
        waterLiters: row.waterLiters,
        weightKg: row.weightKg,
      );
      sent.add(row);
    }

    if (sent.isNotEmpty) await _db.markDailyLogsSynced(sent);
  }

  /// Simpan perubahan lokal hari ini lalu coba kirim ke server.
  Future<void> saveToday({
    required DateTime date,
    int? steps,
    double? waterLiters,
    double? weightKg,
  }) async {
    await _db.setLocalTodayLog(
      logDate: localDateString(date),
      steps: steps,
      waterLiters: waterLiters,
      weightKg: weightKg,
    );
    await pushPending();
    await pullToday();
  }

  Future<TargetEntry?> readTarget() => _db.getTarget();

  Future<DailyLogEntry?> readLog(String logDate) => _db.getDailyLog(logDate);

  Future<List<DailyLogEntry>> readLogsSince(String fromDate) =>
      _db.getDailyLogsSince(fromDate);
}
