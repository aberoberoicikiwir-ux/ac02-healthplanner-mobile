import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/local/app_database.dart';
import 'data/local/secure_storage_service.dart';
import 'data/local/settings_service.dart';
import 'data/remote/fake_api_service.dart';
import 'data/repositories/workout_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/workout_provider.dart';
import 'screens/health_profile_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  // Wajib karena kita memakai plugin (shared_preferences, secure storage)
  // SEBELUM runApp.
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final settingsService = SettingsService(prefs);
  final secureStorage = SecureStorageService();
  final api = FakeApiService(settingsService);
  final database = AppDatabase();
  final workoutRepository = WorkoutRepository(database, api);

  // Cek apakah token login masih tersimpan (dari sesi sebelumnya).
  final authProvider = AuthProvider(api, secureStorage);
  await authProvider.restoreSession();

  runApp(
    // MultiProvider = menaruh beberapa Global State di level paling atas app.
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(
            create: (context) => SettingsProvider(settingsService)),
        ChangeNotifierProvider(
            create: (context) => WorkoutProvider(workoutRepository)),
      ],
      child: HealthPlannerApp(startLoggedIn: authProvider.isLoggedIn),
    ),
  );
}

class HealthPlannerApp extends StatelessWidget {
  const HealthPlannerApp({super.key, required this.startLoggedIn});

  final bool startLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthmaxxing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
      // Sudah login sebelumnya -> langsung masuk, tidak perlu login lagi.
      home: startLoggedIn ? const HealthProfileGate() : const LoginScreen(),
    );
  }
}
