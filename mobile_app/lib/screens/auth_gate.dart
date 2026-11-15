import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'health_profile_screen.dart';
import 'login_screen.dart';

/// Menentukan layar berdasarkan status login. Kalau token habis (401),
/// AuthProvider berubah -> layar otomatis kembali ke LoginScreen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isLoggedIn) return const LoginScreen();
        return const HealthProfileGate();
      },
    );
  }
}
