import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import 'workout_detail_screen.dart';

class WorkoutPlanScreen extends StatelessWidget {
  const WorkoutPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8E9AAF), Color(0xFF6E7B94)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Text('Workout Plan',
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w300, color: Colors.white)),
              const SizedBox(height: 12),
              Image.asset('assets/images/logo.png', height: 50),
              const SizedBox(height: 20),
              Expanded(
                child: Consumer<WorkoutProvider>(
                  builder: (context, workoutProvider, child) {
                    final workouts = workoutProvider.workouts;
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: workouts.length,
                      itemBuilder: (context, index) {
                        final w = workouts[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white38),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E3A8A),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.fitness_center,
                                  color: Colors.tealAccent),
                            ),
                            title: Text(w.name,
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text(w.detail,
                                style: const TextStyle(color: Colors.white60)),
                            trailing: w.isDone
                                ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                                : const Icon(Icons.chevron_right, color: Colors.white70),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        WorkoutDetailScreen(workoutId: w.id)),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}