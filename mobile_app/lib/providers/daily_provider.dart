import 'package:flutter/material.dart';

import '../data/local/app_database.dart';
import '../data/remote/api_service.dart';
import '../data/repositories/daily_repository.dart';
import '../utils/formatters.dart';

class DailyProvider extends ChangeNotifier {
  DailyProvider(this._repository);

  final DailyRepository _repository;

  TargetEntry? _target;
  DailyLogEntry? _todayLog;
  List<DailyLogEntry> _history = [];
  bool _loading = false;
  String? _errorMessage;

  TargetEntry? get target => _target;
  DailyLogEntry? get todayLog => _todayLog;
  List<DailyLogEntry> get history => _history;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAll() async {
    if (_loading) return;
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.pushPending();
      await _repository.pullTarget();
      await _repository.pullToday();
      await _repository.pullHistory();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    }

    await _refreshFromCache();
    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() => loadAll();

  Future<void> _refreshFromCache() async {
    final now = DateTime.now();
    _target = await _repository.readTarget();
    _history = await _repository.readLogsSince(
      localDateString(now.subtract(const Duration(days: 29))),
    );

    final todayKey = localDateString(now);
    DailyLogEntry? today;
    for (final row in _history) {
      if (row.logDate == todayKey) {
        today = row;
        break;
      }
    }
    // Kalau tanggal server berbeda dari tanggal HP, pakai baris terbaru.
    if (today == null && _history.isNotEmpty) today = _history.last;
    _todayLog = today;
  }

  Future<bool> saveToday({
    int? steps,
    double? waterLiters,
    double? weightKg,
  }) async {
    _errorMessage = null;
    try {
      await _repository.saveToday(
        date: DateTime.now(),
        steps: steps,
        waterLiters: waterLiters,
        weightKg: weightKg,
      );
    } on ApiException catch (e) {
      _errorMessage = e.message;
    }

    await _refreshFromCache();
    notifyListeners();
    return _errorMessage == null;
  }

  /// Data untuk grafik: hanya baris yang punya nilai.
  List<DailyLogEntry> get weightPoints =>
      _history.where((e) => e.weightKg != null).toList();

  List<DailyLogEntry> get stepPoints =>
      _history.where((e) => e.steps != null).toList();

  void reset() {
    _target = null;
    _todayLog = null;
    _history = [];
    _loading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
