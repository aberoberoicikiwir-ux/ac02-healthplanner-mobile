import 'package:flutter/material.dart';
import '../models/workout.dart';

// ChangeNotifier = kelas dasar Flutter buat bikin "Global State"
class WorkoutProvider extends ChangeNotifier {
  final List<Workout> _workouts = [
    Workout(
      id: '1',
      name: 'Push Up',
      detail: '3 sets x 15 reps',
      benefit:
          'This exercise works the chest, shoulders, and triceps. Keep '
              'your body straight from head to heels throughout the movement.',
    ),
    Workout(
      id: '2',
      name: 'Squat',
      detail: '3 sets x 20 reps',
      benefit:
          'This exercise works the thighs and glutes. Keep your knees '
              'behind your toes when bending.',
    ),
    Workout(
      id: '3',
      name: 'Plank',
      detail: '3 sets x 45 sec',
      benefit:
          'This exercise strengthens the core. Keep your back flat, '
              'avoid letting your hips sag or rise.',
    ),
  ];

  List<Workout> get workouts => _workouts;

  int get completedCount => _workouts.where((w) => w.isDone).length;
  int get totalCount => _workouts.length;

  void toggleDone(String id) {
    final workout = _workouts.firstWhere((w) => w.id == id);
    workout.isDone = !workout.isDone;
    // notifyListeners() = "siaran" ke SEMUA widget yang "dengerin" provider
    // ini, supaya mereka rebuild otomatis dengan data terbaru.
    notifyListeners();
  }
}