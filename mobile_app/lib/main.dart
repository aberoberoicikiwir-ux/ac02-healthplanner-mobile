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
      home: const LoginScreen(),
      routes: {
        '/workout': (context) => const WorkoutPlanScreen(),
        '/meal': (context) => const MealPlanScreen(),
      },
    );
  }
}

// ===== LOGIN SCREEN =====
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite, size: 64, color: Colors.teal),
              const SizedBox(height: 12),
              const Text(
                'Health & Workout Planner',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    // Ganti halaman ini secara PERMANEN (pushReplacement),
                    // supaya tombol back nggak balik ke Login lagi.
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HealthProfileGate()),
                    );
                  },
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== CEK HEALTH PROFILE =====
// Widget ini simulasi "Cek HealthProfile" di schema: kalau data kosong,
// tampilkan form dulu. Kalau sudah lengkap, langsung ke MainNavigationScreen.
class HealthProfileGate extends StatefulWidget {
  const HealthProfileGate({super.key});

  @override
  State<HealthProfileGate> createState() => _HealthProfileGateState();
}

class _HealthProfileGateState extends State<HealthProfileGate> {
  // Simulasi: anggap data klien ini masih kosong.
  // Nanti diganti hasil cek API sungguhan ke backend.
  final bool _hasHealthProfile = false;

  @override
  Widget build(BuildContext context) {
    if (_hasHealthProfile) {
      return const MainNavigationScreen();
    }
    return const HealthProfileFormScreen();
  }
}

class HealthProfileFormScreen extends StatelessWidget {
  const HealthProfileFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lengkapi Data Kesehatan')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sebelum mulai, isi dulu data ini ya:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Berat Badan (kg)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Target (misal: turun 5kg dalam 2 bulan)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Alergi (kosongkan jika tidak ada)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  // Submit -> lanjut ke Main App, gantikan halaman form ini
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MainNavigationScreen()),
                  );
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== MAIN APP: Bottom Navigation Bar (4 tab final) =====
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [
    TodaysTargetTab(),
    ProgresTab(),
    InsightAiTab(),
    ProfilTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // biar label tetap muncul di 4 tab
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: "Today's Target"),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progres'),
          BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome), label: 'Insight'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// ===== TAB 1: Today's Target (+ shortcut Workout & Meal) =====
class TodaysTargetTab extends StatelessWidget {
  const TodaysTargetTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Today's Target")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Halo, Abero!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Ini target dan progres harianmu hari ini.',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
            Row(
              children: [
                Expanded(
                  child: _buildShortcutCard(
                    context: context,
                    icon: Icons.fitness_center,
                    label: 'Workout Plan',
                    routeName: '/workout',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildShortcutCard(
                    context: context,
                    icon: Icons.restaurant_menu,
                    label: 'Meal Plan',
                    routeName: '/meal',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String routeName,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, routeName),
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

// ===== TAB 2: Progres (placeholder) =====
class ProgresTab extends StatelessWidget {
  const ProgresTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progres')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Grafik berat badan & langkah harian dari waktu ke waktu '
            'akan tampil di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

// ===== TAB 3: Insight AI (placeholder) =====
class InsightAiTab extends StatelessWidget {
  const InsightAiTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insight AI')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.teal.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.teal),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Feedback & rekomendasi dari AI berdasarkan histori '
                    'berat badan dan aktivitasmu akan tampil di sini.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===== TAB 4: Profil (placeholder) =====
class ProfilTab extends StatelessWidget {
  const ProfilTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            CircleAvatar(radius: 32, child: Icon(Icons.person, size: 32)),
            SizedBox(height: 16),
            Text('Abero',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Klien', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 24),
            Text(
              'Health profile (berat, target, alergi) bisa dilihat/diedit '
              'di sini.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Screen 1: Workout Plan (Katalog) — WAJIB StatelessWidget =====
class WorkoutPlanScreen extends StatelessWidget {
  const WorkoutPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dipangkas jadi 3 item sesuai requirement tugas
    final workouts = [
      {
        'name': 'Push Up',
        'detail': '3 set x 15 repetisi',
        'description':
            'Latihan ini melatih otot dada, bahu, dan trisep. Jaga posisi '
                'tubuh tetap lurus dari kepala hingga tumit selama gerakan.',
      },
      {
        'name': 'Squat',
        'detail': '3 set x 20 repetisi',
        'description':
            'Latihan ini melatih otot paha dan bokong. Pastikan lutut '
                'tidak melewati ujung jari kaki saat menekuk.',
      },
      {
        'name': 'Plank',
        'detail': '3 set x 45 detik',
        'description':
            'Latihan ini melatih otot inti (core). Jaga punggung tetap '
                'rata, jangan biarkan pinggul turun atau naik.',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Plan')),
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
              trailing: const Icon(Icons.chevron_right),
              // Klik title/tile -> pindah ke Screen 2 pakai Navigator.push
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutDetailScreen(
                      name: item['name']!,
                      detail: item['detail']!,
                      description: item['description']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ===== Screen 2: Detail Katalog — WAJIB StatefulWidget =====
class WorkoutDetailScreen extends StatefulWidget {
  final String name;
  final String detail;
  final String description;

  const WorkoutDetailScreen({
    super.key,
    required this.name,
    required this.detail,
    required this.description,
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  // Ini "state" yang berubah interaktif waktu tombol ditekan
  bool _isDone = false;

  void _toggleDone() {
    setState(() {
      _isDone = !_isDone; // membalik nilai true/false
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar otomatis kasih tombol back bawaan (sesuai requirement e)
      appBar: AppBar(title: Text(widget.name)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column( // wajib pakai Column (requirement c)
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon back tambahan di body (requirement d - poin 1)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text('Kembali ke Katalog',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),

            // Text nama & detail (requirement d - poin 2)
            Text(
              widget.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.detail,
              style: const TextStyle(fontSize: 16, color: Colors.teal),
            ),
            const SizedBox(height: 16),

            // Container pastel + padding buat deskripsi (requirement d - poin 3)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50, // warna pastel
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.description,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol interaktif -> ubah STATE saat ditekan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _toggleDone,
                icon: Icon(_isDone ? Icons.check_circle : Icons.circle_outlined),
                label: Text(_isDone ? 'Selesai ✓' : 'Tandai Selesai'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isDone ? Colors.green : Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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