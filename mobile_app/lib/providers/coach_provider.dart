import 'dart:async';

import 'package:flutter/material.dart';

import '../data/repositories/coach_repository.dart';
import '../models/coach_message.dart';

class CoachProvider extends ChangeNotifier {
  CoachProvider(this._repository) {
    _subscription = _repository.watchMessages().listen((data) {
      _messages = data;
      notifyListeners();
    });
  }

  final CoachRepository _repository;
  StreamSubscription<List<CoachMessage>>? _subscription;

  List<CoachMessage> _messages = [];
  bool _loading = false;
  bool _loaded = false;
  bool _sending = false;
  String? _pendingMessage;
  String? _errorMessage;

  List<CoachMessage> get messages => _messages;
  bool get loading => _loading;
  bool get loaded => _loaded;
  bool get sending => _sending;
  String? get pendingMessage => _pendingMessage;
  String? get errorMessage => _errorMessage;

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

  Future<bool> send(String text) async {
    final message = text.trim();
    if (message.isEmpty || _sending) return false;

    _sending = true;
    _pendingMessage = message;
    _errorMessage = null;
    notifyListeners();

    var ok = false;
    try {
      await _repository.send(message);
      ok = true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    _sending = false;
    _pendingMessage = null;
    notifyListeners();
    return ok;
  }

  Future<void> clearHistory() async {
    try {
      await _repository.clear();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  void reset() {
    _messages = [];
    _loading = false;
    _loaded = false;
    _sending = false;
    _pendingMessage = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
