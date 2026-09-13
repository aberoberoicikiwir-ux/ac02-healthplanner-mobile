import 'package:flutter/material.dart';

void main() {
  runApp(const HealthPlannerApp());
}

class HealthPlannerApp extends StatelessWidget {
  const HealthPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health & Workout Planner',
      theme: ThemeData(primarySwatch: Colors.teal),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/workout': (context) => const WorkoutPlanScreen(),
        '/meal': (context) => const MealPlanScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health & Workout Planner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Halo, Abero!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ini target dan progres harianmu hari ini.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Langkah Hari Ini',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text('3.240 / 8.000 langkah'),
                      ],
                    ),
                    const Icon(Icons.directions_walk,
                        size: 40, color: Colors.teal),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Row: dua Card yang sekarang BISA DIKLIK buat pindah halaman
            Row(
              children: [
                Expanded(
                  child: _buildShortcutCard(
                    context: context,
                    icon: Icons.fitness_center,
                    label: 'Workout Plan',
                    routeName: '/workout', // <-- tujuan navigasi
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildShortcutCard(
                    context: context,
                    icon: Icons.restaurant_menu,
                    label: 'Meal Plan',
                    routeName: '/meal', // <-- tujuan navigasi
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 1) {
            Navigator.pushNamed(context, '/workout');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/meal');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: "Today's Target",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Meal Plan',
          ),
        ],
      ),
    );
  }

  // Sekarang widget ini butuh context & routeName biar bisa navigasi
  Widget _buildShortcutCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String routeName,
  }) {
    return InkWell(
      // InkWell = bikin widget lain jadi "bisa diklik" dengan efek ripple
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.teal),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== HALAMAN BARU: Workout Plan =====
class WorkoutPlanScreen extends StatelessWidget {
  const WorkoutPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workouts = [
      {'name': 'Push Up', 'detail': '3 set x 15 repetisi'},
      {'name': 'Squat', 'detail': '3 set x 20 repetisi'},
      {'name': 'Plank', 'detail': '3 set x 45 detik'},
      {'name': 'Jogging', 'detail': '20 menit'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Plan')),
      // Tombol back otomatis muncul di sini karena halaman ini dibuka via Navigator.push
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          final item = workouts[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.fitness_center, color: Colors.teal),
              title: Text(item['name']!),
              subtitle: Text(item['detail']!),
              trailing: Checkbox(value: false, onChanged: (_) {}),
            ),
          );
        },
      ),
    );
  }
}

// ===== HALAMAN BARU: Meal Plan =====
class MealPlanScreen extends StatelessWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final meals = [
      {'name': 'Oatmeal & Buah', 'detail': 'Sarapan - 350 kkal'},
      {'name': 'Dada Ayam Panggang & Sayur', 'detail': 'Makan Siang - 500 kkal'},
      {'name': 'Salad Tuna', 'detail': 'Makan Malam - 400 kkal'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Meal Plan')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: meals.length,
        itemBuilder: (context, index) {
          final item = meals[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.restaurant_menu, color: Colors.teal),
              title: Text(item['name']!),
              subtitle: Text(item['detail']!),
              trailing: Checkbox(value: false, onChanged: (_) {}),
            ),
          );
        },
      ),
    );
  }
}