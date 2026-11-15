import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/utils/formatters.dart';

void main() {
  test('workoutDetail membedakan strength dan cardio', () {
    expect(
      workoutDetail(sets: 3, reps: 10, category: 'strength'),
      '3 sets x 10 reps',
    );
    expect(workoutDetail(sets: 1, reps: 20, category: 'cardio'), '20 menit');
    expect(
      workoutDetail(sets: 1, reps: 15, category: 'flexibility'),
      '15 menit',
    );
  });

  test('label hari dan waktu makan', () {
    expect(dayLabel('mon'), 'Senin');
    expect(dayLabel(null), 'Tanpa hari');
    expect(mealTypeLabel('breakfast'), 'Sarapan');
    expect(mealTypeLabel('lunch'), 'Makan Siang');
  });

  test('localDateString memakai format YYYY-MM-DD', () {
    expect(localDateString(DateTime(2026, 1, 5)), '2026-01-05');
  });
}
