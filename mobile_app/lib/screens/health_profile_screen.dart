import 'package:flutter/material.dart';
import 'main_navigation_screen.dart';

class HealthProfileGate extends StatefulWidget {
  const HealthProfileGate({super.key});

  @override
  State<HealthProfileGate> createState() => _HealthProfileGateState();
}

class _HealthProfileGateState extends State<HealthProfileGate> {
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
            const Text('Sebelum mulai, isi dulu data ini ya:',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Berat Badan (kg)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Target',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Alergi',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
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