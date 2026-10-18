import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final String workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context) {
    // PENTING: Scaffold WAJIB ada. Tanpa Scaffold (Material), teks memakai
    // gaya darurat Flutter: besar, merah, garis bawah kuning ganda.
   return Scaffold(
     body: Container(
       width: double.infinity,
       height: double.infinity,
       decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8E9AAF), Color(0xFF6E7B94)],
          ),
        ),
        child: SafeArea(
          // Consumer: tombol & teks status update begitu ditekan
          // (membaca dari Global State yang bersumber dari database).
          child: Consumer<WorkoutProvider>(
            builder: (context, workoutProvider, child) {
              final matches =
                  workoutProvider.workouts.where((w) => w.id == workoutId);
              if (matches.isEmpty) {
                return const SizedBox.shrink();
              }
              final workout = matches.first;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Center(
                        child:
                            Image.asset('assets/images/logo.png', height: 80)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            workout.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(workout.detail,
                              style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Benefit',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                Text(workout.benefit,
                                    style: const TextStyle(
                                        color: Colors.white70, height: 1.4)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Tulis ke database lewat provider -> stream
                                // database memicu update di SEMUA screen.
                                workoutProvider.toggleDone(workout.id);
                              },
                              icon: Icon(workout.isDone
                                  ? Icons.check_circle
                                  : Icons.circle_outlined),
                              label: Text(workout.isDone
                                  ? 'Selesai ✓'
                                  : 'Tandai Selesai'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: workout.isDone
                                    ? Colors.green
                                    : const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
