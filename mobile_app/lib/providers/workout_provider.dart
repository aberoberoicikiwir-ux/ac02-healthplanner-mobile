import 'dart:async';

import 'package:flutter/material.dart';
import '../data/repositories/workout_repository.dart';
import '../models/workout.dart';

/// Global State untuk latihan. Sumber datanya sekarang database (Drift),
/// bukan list yang ditulis manual di sini.
class WorkoutProvider extends ChangeNotifier {
  WorkoutProvider(this._repository) {
    // Dengarkan stream database: tiap tabel berubah -> list diperbarui
    // -> notifyListeners() -> semua screen yang memakai Consumer ikut rebuild.
    _subscription = _repository.watchWorkouts().listen((data) {
      _workouts = data;
      notifyListeners();
    });
    refresh();
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

  /// Waktu sinkron terakhir (jam lokal), null kalau belum pernah sinkron.
  DateTime? get lastSynced {
    if (_workouts.isEmpty) return null;
    final latest = _workouts
        .map((w) => w.lastFetched)
        .reduce((a, b) => a > b ? a : b);
    if (latest == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(latest, isUtc: true).toLocal();
  }

  Future<void> refresh() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.refreshFromServer();
    } catch (_) {
      _errorMessage = 'Gagal sinkron. Menampilkan data tersimpan.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleDone(String id) async {
    final workout = _workouts.firstWhere((w) => w.id == id);
    // Cukup tulis ke database; stream di atas yang akan memperbarui UI.
    await _repository.setDone(id, !workout.isDone);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
