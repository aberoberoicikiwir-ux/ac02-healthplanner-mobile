import 'dart:async';

import 'package:flutter/material.dart';
import '../data/repositories/workout_repository.dart';
import '../models/workout.dart';

/// Global State untuk latihan. Sumber datanya database (Drift).
class WorkoutProvider extends ChangeNotifier {
  WorkoutProvider(this._repository) {
    // Dengarkan stream database: tiap tabel berubah -> list diperbarui
    // -> notifyListeners() -> semua screen yang memakai Consumer ikut rebuild.
    _subscription = _repository.watchWorkouts().listen((data) {
      _workouts = data;
      notifyListeners();
    });
    sync();
  }

  final WorkoutRepository _repository;
  StreamSubscription<List<Workout>>? _subscription;

  List<Workout> _workouts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Workout> get workouts => _workouts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get completedCount => _workouts.where((w) => w.isDone).length;
  int get totalCount => _workouts.length;

  /// Jumlah baris dengan perubahan lokal yang belum dikirim ke server.
  int get pendingCount => _workouts.where((w) => !w.synced).length;

  /// Waktu sinkron terakhir (jam lokal), null kalau belum pernah sinkron.
  DateTime? get lastSynced {
    if (_workouts.isEmpty) return null;
    final latest = _workouts
        .map((w) => w.lastFetched)
        .reduce((a, b) => a > b ? a : b);
    if (latest == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(latest, isUtc: true).toLocal();
  }

  /// Sinkronisasi dua arah: kirim perubahan lokal, lalu ambil data terbaru.
  Future<void> sync() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.pushPending();
      await _repository.pullFromServer();
    } catch (_) {
      _errorMessage = 'Gagal sinkron. Menampilkan data tersimpan.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleDone(String id) async {
    final workout = _workouts.firstWhere((w) => w.id == id);
    // Cukup tulis ke database; stream di atas yang memperbarui UI.
    await _repository.setDone(id, !workout.isDone);
  }

  Future<void> addWorkout({
    required String name,
    required String detail,
  }) async {
    final id = 'local-${DateTime.now().toUtc().millisecondsSinceEpoch}';
    await _repository.addWorkout(
      id: id,
      name: name.trim(),
      detail: detail.trim(),
      benefit: 'Latihan tambahan yang dicatat sendiri.',
    );
  }

  Future<void> deleteWorkout(String id) => _repository.deleteWorkout(id);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
