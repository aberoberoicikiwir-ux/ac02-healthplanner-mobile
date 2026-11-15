import 'package:drift/drift.dart' show Value;

import '../../models/meal.dart';
import '../local/app_database.dart';
import '../remote/api_service.dart';

class MealRepository {
  MealRepository(this._db, this._api);

  final AppDatabase _db;
  final ApiService _api;

  Stream<List<Meal>> watchMeals() {
    return _db.watchAllMeals().map((rows) => rows.map(_toModel).toList());
  }

  Future<void> pushPending() async {
    final pending = await _db.getUnsyncedMeals();
    final sent = <MealEntry>[];

    for (final row in pending) {
      try {
        await _api.patchMealItem(row.id, row.isDone);
        sent.add(row);
      } on ApiException catch (e) {
        if (e.isNotFound) {
          await _db.deleteMeal(row.id);
        } else {
          rethrow;
        }
      }
    }

    if (sent.isNotEmpty) await _db.markMealsSynced(sent);
  }

  Future<void> pullFromServer() async {
    final plan = await _api.getCurrentMealPlan();
    final rawItems = plan?['items'];
    final items = rawItems is List ? rawItems : const [];
    final now = nowUtcMillis();

    final rows = <MealEntriesCompanion>[];
    for (final raw in items) {
      if (raw is! Map<String, dynamic>) continue;
      final id = raw['item_id']?.toString();
      final mealType = raw['meal_type']?.toString();
      final foodName = raw['food_name']?.toString();
      if (id == null || mealType == null || foodName == null) continue;

      rows.add(
        MealEntriesCompanion.insert(
          id: id,
          dayOfWeek: Value(raw['day_of_week']?.toString()),
          mealType: mealType,
          foodName: foodName,
          calories: Value((raw['calories'] as num?)?.toInt()),
          proteinG: Value((raw['protein_g'] as num?)?.toDouble()),
          carbsG: Value((raw['carbs_g'] as num?)?.toDouble()),
          fatG: Value((raw['fat_g'] as num?)?.toDouble()),
          isDone: Value(raw['is_completed'] == true),
          lastFetched: now,
          updatedAt: Value(now),
          synced: const Value(true),
        ),
      );
    }

    await _db.upsertServerMeals(rows);
    await _db.deleteStaleServerMeals(rows.map((r) => r.id.value).toSet());
  }

  Future<void> setDone(String id, bool value) => _db.setMealDone(id, value);

  Meal _toModel(MealEntry e) => Meal(
    id: e.id,
    dayOfWeek: e.dayOfWeek,
    mealType: e.mealType,
    foodName: e.foodName,
    calories: e.calories,
    proteinG: e.proteinG,
    carbsG: e.carbsG,
    fatG: e.fatG,
    isDone: e.isDone,
    lastFetched: e.lastFetched,
    updatedAt: e.updatedAt,
    synced: e.synced,
  );
}
