class StreakService {
  int calculateStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    dates.sort((a, b) => b.compareTo(a));

    int streak = 1;

    for (int i = 0; i < dates.length - 1; i++) {
      final diff = dates[i].difference(dates[i + 1]).inDays;

      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
