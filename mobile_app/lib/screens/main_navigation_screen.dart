import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/daily_provider.dart';
import '../providers/meal_provider.dart';
import '../providers/workout_provider.dart';
import 'todays_target_tab.dart';
import 'progres_tab.dart';
import 'insight_ai_tab.dart';
import 'profil_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().sync();
      context.read<MealProvider>().sync();
      context.read<DailyProvider>().loadAll();
    });
  }

  final List<Widget> _tabs = const [
    TodaysTargetTab(),
    ProgresTab(),
    InsightAiTab(),
    ProfilTab(),
  ];

  final List<Map<String, dynamic>> _navItems = const [
    {'icon': Icons.flag_outlined, 'label': "Target"},
    {'icon': Icons.show_chart, 'label': 'Progres'},
    {'icon': Icons.auto_awesome, 'label': 'Insight'},
    {'icon': Icons.person_outline, 'label': 'Profil'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_navItems.length, (index) {
              final isSelected = _selectedIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _navItems[index]['icon'],
                      color: isSelected ? Colors.white : Colors.white38,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _navItems[index]['label'],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.white38,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
