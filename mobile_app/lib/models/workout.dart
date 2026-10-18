class Workout {
  final String id;
  final String name;
  final String detail;
  final String benefit;
  final bool isDone;

  /// Waktu terakhir data diambil dari server (UTC milliseconds).
  final int lastFetched;

  /// Waktu terakhir diubah di perangkat (UTC milliseconds).
  final int updatedAt;

  /// false = ada perubahan lokal yang belum dikirim ke server.
  final bool synced;

  const Workout({
    required this.id,
    required this.name,
    required this.detail,
    required this.benefit,
    this.isDone = false,
    this.lastFetched = 0,
    this.updatedAt = 0,
    this.synced = true,
  });

  /// Latihan yang dibuat pengguna sendiri (id diawali "local-").
  /// Hanya jenis ini yang boleh dihapus; rencana dari server tidak.
  bool get isLocal => id.startsWith('local-');
}
