import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/local/app_database.dart';
import 'data/local/secure_storage_service.dart';
import 'data/local/settings_service.dart';
import 'data/remote/api_service.dart';
import 'data/repositories/daily_repository.dart';
import 'data/repositories/meal_repository.dart';
import 'data/repositories/coach_repository.dart';
import 'data/repositories/insight_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/workout_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/coach_provider.dart';
import 'providers/daily_provider.dart';
import 'providers/insight_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/workout_provider.dart';
import 'screens/auth_gate.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.backgroundTop,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

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
  final insightProvider = InsightProvider(InsightRepository(database, api));
  final coachProvider = CoachProvider(CoachRepository(database, api));

  // Saat logout / token habis / login akun baru: hapus cache lokal supaya
  // akun berikutnya tidak melihat data akun sebelumnya.
  Future<void> clearLocalData() async {
    await database.clearUserData();
    profileProvider.reset();
    workoutProvider.reset();
    mealProvider.reset();
    dailyProvider.reset();
    insightProvider.reset();
    coachProvider.reset();
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
        ChangeNotifierProvider.value(value: insightProvider),
        ChangeNotifierProvider.value(value: coachProvider),
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
      theme: buildAppTheme(),
      darkTheme: buildAppTheme(),
      themeMode: ThemeMode.dark,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: AppColors.backgroundTop,
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarDividerColor: Colors.transparent,
          ),
          child: MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          ),
        );
      },
      home: const AuthGate(),
    );
  }
}
