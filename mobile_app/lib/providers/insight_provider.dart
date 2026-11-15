import 'dart:async';

import 'package:flutter/material.dart';

import '../data/repositories/insight_repository.dart';
import '../models/insight_notification.dart';

class InsightProvider extends ChangeNotifier {
  InsightProvider(this._repository) {
    _subscription = _repository.watchNotifications().listen((data) {
      _notifications = data;
      notifyListeners();
    });
  }

  final InsightRepository _repository;
  StreamSubscription<List<InsightNotification>>? _subscription;

  List<InsightNotification> _notifications = [];
  bool _loading = false;
  bool _loaded = false;
  String? _errorMessage;

  List<InsightNotification> get notifications => _notifications;
  bool get loading => _loading;
  bool get loaded => _loaded;
  String? get errorMessage => _errorMessage;

  List<InsightNotification> get aiInsights =>
      _notifications.where((n) => n.isAiInsight).toList();

  List<InsightNotification> get otherNotifications =>
      _notifications.where((n) => !n.isAiInsight).toList();

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> load({bool force = false}) async {
    if (_loading) return;
    if (_loaded && !force) return;

    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.refresh();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    _loading = false;
    _loaded = true;
    notifyListeners();
  }

  Future<void> refresh() => load(force: true);

  Future<void> markRead(int id) async {
    try {
      await _repository.markRead(id);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void reset() {
    _notifications = [];
    _loading = false;
    _loaded = false;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
