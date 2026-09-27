import 'package:flutter/material.dart';

class InsightAiTab extends StatelessWidget {
  const InsightAiTab({super.key});

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
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text('Insight AI',
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w300, color: Colors.white)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.tealAccent),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Feedback & rekomendasi dari AI berdasarkan histori berat badan dan aktivitasmu akan tampil di sini.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}