import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/screens/login_screen.dart';

void main() {
  testWidgets('Login screen tampil saat belum login', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    expect(find.text('HEALTHMAXXING'), findsOneWidget);
    expect(find.text('LOG IN'), findsOneWidget);
  });
}
