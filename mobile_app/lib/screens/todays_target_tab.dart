import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import 'workout_plan_screen.dart';
import 'meal_plan_screen.dart';

class TodaysTargetTab extends StatelessWidget {
  const TodaysTargetTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8E9AAF), Color(0xFF6E7B94)],
        ),
      ),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Health & Workout Planner',
                  style: TextStyle(fontSize: 16)),
              background: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Image.asset('assets/images/logo.png', height: 70),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text('Hello, User!',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const Text("Today's target",
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 20),

                Consumer<WorkoutProvider>(
                  builder: (context, workoutProvider, child) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Latihan Selesai',
                                  style: TextStyle(color: Colors.white)),
                              const SizedBox(height: 4),
                              Text(
                                '${workoutProvider.completedCount} / ${workoutProvider.totalCount} latihan',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Icon(Icons.directions_walk,
                              size: 36, color: Colors.white),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Shortcut ke Workout Plan & Meal Plan -- gaya card sama
                // kayak yang di list Workout Plan (icon box biru rounded),
                // biar konsisten sama tema Figma.
                Row(
                  children: [
                    Expanded(
                      child: _shortcutCard(
                        context: context,
                        icon: Icons.fitness_center,
                        label: 'Workout Plan',
                        page: const WorkoutPlanScreen(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _shortcutCard(
                        context: context,
                        icon: Icons.restaurant_menu,
                        label: 'Meal Plan',
                        page: const MealPlanScreen(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shortcutCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Widget page,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white38),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.tealAccent),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}