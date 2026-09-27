import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/workout_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(
    // ChangeNotifierProvider = "menaruh" WorkoutProvider di level PALING
    // ATAS app, supaya SEMUA screen di bawahnya bisa mengakses data yang
    // sama itu (inilah yang disebut Global State).
    ChangeNotifierProvider(
      create: (context) => WorkoutProvider(),
      child: const HealthPlannerApp(),
    ),
  );
}

class HealthPlannerApp extends StatelessWidget {
  const HealthPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthmaxxing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}