import 'package:flutter/material.dart';

import '../data/remote/api_service.dart';
import '../data/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._repository);

  final ProfileRepository _repository;

  Map<String, dynamic>? _profile;
  bool _loading = false;
  bool _loaded = false;
  String? _errorMessage;

  Map<String, dynamic>? get profile => _profile;
  bool get loading => _loading;
  bool get loaded => _loaded;
  String? get errorMessage => _errorMessage;

  num? get weightCurrent => _profile?['weight_current'] as num?;
  num? get weightTarget => _profile?['weight_target'] as num?;
  num? get heightCm => _profile?['height_cm'] as num?;
  String? get allergies => _profile?['allergies']?.toString();
  String? get gender => _profile?['gender']?.toString();
  String? get birthDate => _profile?['birth_date']?.toString();
  String? get activityLevel => _profile?['activity_level']?.toString();
  bool get hasPt => _profile?['assigned_pt_id'] != null;

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.fetchAndCache();
    } on ApiException catch (e) {
      final cached = await _repository.readCache();
      if (cached != null) _profile = cached;
      _errorMessage = e.message;
    } finally {
      _loading = false;
      _loaded = true;
      notifyListeners();
    }
  }

  Future<bool> createProfile(Map<String, dynamic> body) =>
      _save(() => _repository.createProfile(body));

  Future<bool> updateProfile(Map<String, dynamic> body) =>
      _save(() => _repository.updateProfile(body));

  Future<bool> choosePt(String ptUsername) =>
      _save(() => _repository.choosePt(ptUsername));

  Future<bool> _save(Future<void> Function() action) async {
    _errorMessage = null;
    try {
      await action();
      await load();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _profile = null;
    _loading = false;
    _loaded = false;
    _errorMessage = null;
    notifyListeners();
  }
}
