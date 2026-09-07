import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('Home screen shows greeting text', (WidgetTester tester) async {
    await tester.pumpWidget(const HealthPlannerApp());

    expect(find.text('Halo, Abero!'), findsOneWidget);
  });
}