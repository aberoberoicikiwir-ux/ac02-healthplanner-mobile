class Workout {
  final String id;
  final String name;
  final String detail;
  final String benefit;
  bool isDone;

  Workout({
    required this.id,
    required this.name,
    required this.detail,
    required this.benefit,
    this.isDone = false,
  });
}