class Meal {
  final String id;
  final String? dayOfWeek;
  final String mealType;
  final String foodName;
  final int? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final bool isDone;
  final int lastFetched;
  final int updatedAt;
  final bool synced;

  const Meal({
    required this.id,
    required this.dayOfWeek,
    required this.mealType,
    required this.foodName,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.isDone = false,
    this.lastFetched = 0,
    this.updatedAt = 0,
    this.synced = true,
  });
}
