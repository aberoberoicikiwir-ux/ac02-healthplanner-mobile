class Workout {
  final String id;
  final String name;
  final String detail;
  final String benefit;
  final bool isDone;

  /// Waktu terakhir data diambil dari server (UTC milliseconds).
  final int lastFetched;

  const Workout({
    required this.id,
    required this.name,
    required this.detail,
    required this.benefit,
    this.isDone = false,
    this.lastFetched = 0,
  });
}
