import 'dart:async';

import 'package:flutter/material.dart';

import '../data/repositories/meal_repository.dart';
import '../models/meal.dart';

class MealProvider extends ChangeNotifier {
  MealProvider(this._repository) {
    _subscription = _repository.watchMeals().listen((data) {
      _meals = data;
      notifyListeners();
    });
  }

  final MealRepository _repository;
  StreamSubscription<List<Meal>>? _subscription;

  List<Meal> _meals = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Meal> get meals => _meals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get pendingCount => _meals.where((m) => !m.synced).length;
  int get completedCount => _meals.where((m) => m.isDone).length;
  int get totalCount => _meals.length;

  Future<void> sync() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.pushPending();
      await _repository.pullFromServer();
    } catch (_) {
      _errorMessage = 'Gagal sinkron. Menampilkan menu tersimpan.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleDone(String id) async {
    final meal = _meals.firstWhere((m) => m.id == id);
    await _repository.setDone(id, !meal.isDone);
    await sync();
  }

  void reset() {
    _meals = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
