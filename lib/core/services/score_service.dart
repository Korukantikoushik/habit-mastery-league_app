class ScoreService {
  double calculateScore({required int completedDays, required int targetDays}) {
    if (targetDays == 0) return 0;

    final score = (completedDays / targetDays) * 100;

    return score.clamp(0, 100);
  }
}
