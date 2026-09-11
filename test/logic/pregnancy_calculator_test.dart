import 'package:flutter_test/flutter_test.dart';
import 'package:moment/logic/pregnancy_calculator.dart';

void main() {
  group('PregnancyCalculator.babySizeForWeek', () {
    test('maps early weeks to small comparisons', () {
      expect(PregnancyCalculator.babySizeForWeek(1), "Poppy Seed");
      expect(PregnancyCalculator.babySizeForWeek(10), "Lime");
    });

    test('maps late weeks to large comparisons', () {
      expect(PregnancyCalculator.babySizeForWeek(39), "Pumpkin");
      expect(PregnancyCalculator.babySizeForWeek(42), "Watermelon");
    });
  });

  group('PregnancyCalculator.fromDueDate', () {
    test('a due date 280 days out is week 1', () {
      final now = DateTime(2026, 1, 1);
      final dueDate = now.add(const Duration(days: 280));

      final result = PregnancyCalculator.fromDueDate(dueDate, now: now);

      expect(result.currentWeek, 1);
      expect(result.daysLeft, 280);
      expect(result.babySize, "Poppy Seed");
      expect(result.progress, closeTo(1 / 40, 0.001));
    });

    test('a due date 0 days out (today) is week 40', () {
      final now = DateTime(2026, 1, 1);

      final result = PregnancyCalculator.fromDueDate(now, now: now);

      expect(result.currentWeek, 40);
      expect(result.daysLeft, 0);
      // Week 40 lands on the last bucket (>= 40), which is "Watermelon".
      expect(result.babySize, "Watermelon");
      expect(result.progress, 1.0);
    });

    test('an overdue due date clamps at week 42 and full progress', () {
      final now = DateTime(2026, 1, 1);
      final dueDate = now.subtract(const Duration(days: 20));

      final result = PregnancyCalculator.fromDueDate(dueDate, now: now);

      expect(result.currentWeek, 42);
      expect(result.progress, 1.0);
    });
  });
}
