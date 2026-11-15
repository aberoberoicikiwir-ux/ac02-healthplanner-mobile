import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/local/app_database.dart';
import 'data/local/secure_storage_service.dart';
import 'data/local/settings_service.dart';
import 'data/remote/api_service.dart';
import 'data/repositories/daily_repository.dart';
import 'data/repositories/meal_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/workout_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/daily_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/workout_provider.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final settingsService = SettingsService(prefs);
  final secureStorage = SecureStorageService();
  final api = ApiService(settingsService, secureStorage);
  final database = AppDatabase();

  final authProvider = AuthProvider(api, secureStorage);
  await authProvider.restoreSession();

  // Sesi lama (sebelum ada penanda user_id) -> cache lama tidak aman dipakai.
  if (authProvider.needsCacheReset) {
    await database.clearUserData();
  }

  final profileProvider = ProfileProvider(ProfileRepository(database, api));
  final workoutProvider = WorkoutProvider(WorkoutRepository(database, api));
  final mealProvider = MealProvider(MealRepository(database, api));
  final dailyProvider = DailyProvider(DailyRepository(database, api));

  // Saat logout / token habis / login akun baru: hapus cache lokal supaya
  // akun berikutnya tidak melihat data akun sebelumnya.
  Future<void> clearLocalData() async {
    await database.clearUserData();
    profileProvider.reset();
    workoutProvider.reset();
    mealProvider.reset();
    dailyProvider.reset();
  }

  authProvider.onLoggedOut = clearLocalData;
  authProvider.onSessionStart = clearLocalData;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(
          create: (context) => SettingsProvider(settingsService),
        ),
        ChangeNotifierProvider.value(value: profileProvider),
        ChangeNotifierProvider.value(value: workoutProvider),
        ChangeNotifierProvider.value(value: mealProvider),
        ChangeNotifierProvider.value(value: dailyProvider),
      ],
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
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home: const AuthGate(),
    );
  }
}
