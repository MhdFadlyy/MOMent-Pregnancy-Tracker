/// Pure pregnancy-week math, kept free of Firebase/Flutter so it can be
/// unit tested without spinning up the app.
class PregnancyProgress {
  const PregnancyProgress({
    required this.currentWeek,
    required this.daysLeft,
    required this.babySize,
    required this.progress,
  });

  final int currentWeek;
  final int daysLeft;
  final String babySize;
  final double progress;
}

class PregnancyCalculator {
  const PregnancyCalculator._();

  static const int totalPregnancyDays = 280;
  static const int maxWeek = 42;

  /// Fruit-size comparison for a given pregnancy week.
  static String babySizeForWeek(int week) {
    if (week < 4) return "Poppy Seed";
    if (week < 8) return "Blueberry";
    if (week < 12) return "Lime";
    if (week < 16) return "Avocado";
    if (week < 20) return "Banana";
    if (week < 24) return "Ear of Corn";
    if (week < 28) return "Eggplant";
    if (week < 32) return "Squash";
    if (week < 36) return "Honeydew Melon";
    if (week < 40) return "Pumpkin";
    return "Watermelon";
  }

  /// Derives week/days-left/size/progress from a due date, relative to [now]
  /// (defaults to [DateTime.now]).
  static PregnancyProgress fromDueDate(DateTime dueDate, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final daysLeft = dueDate.difference(today).inDays;

    final totalDaysPregnant = totalPregnancyDays - daysLeft;
    int currentWeek = (totalDaysPregnant / 7).ceil();
    if (currentWeek < 1) currentWeek = 1;
    if (currentWeek > maxWeek) currentWeek = maxWeek;

    double progress = currentWeek / 40.0;
    if (progress > 1.0) progress = 1.0;
    if (progress < 0.0) progress = 0.0;

    return PregnancyProgress(
      currentWeek: currentWeek,
      daysLeft: daysLeft,
      babySize: babySizeForWeek(currentWeek),
      progress: progress,
    );
  }
}
