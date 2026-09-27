import 'package:flutter/material.dart';

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
              const Text('Meal Plan',
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w300, color: Colors.white)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final item = meals[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(4),
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
                          child: const Icon(Icons.restaurant_menu,
                              color: Colors.tealAccent),
                        ),
                        title: Text(item['name']!,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(item['detail']!,
                            style: const TextStyle(color: Colors.white60)),
                      ),
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