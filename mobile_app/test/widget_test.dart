import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('Login screen tampil saat belum login', (tester) async {
    await tester.pumpWidget(const HealthPlannerApp(startLoggedIn: false));
    expect(find.text('HEALTHMAXXING'), findsOneWidget);
  });
}