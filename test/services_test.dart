import 'package:flutter_test/flutter_test.dart';
import 'package:habit_mastery_league/core/services/score_service.dart';
import 'package:habit_mastery_league/core/services/streak_service.dart';
import 'package:habit_mastery_league/core/services/ai_buddy_service.dart';

void main() {

  // ================= SCORE TESTS =================
  group('ScoreService Tests', () {
    test('Score is 0 when targetDays is 0', () {
      final service = ScoreService();
      final score = service.calculateScore(completedDays: 5, targetDays: 0);
      expect(score, 0);
    });

    test('Score is 0 when completedDays is 0', () {
      final service = ScoreService();
      final score = service.calculateScore(completedDays: 0, targetDays: 7);
      expect(score, 0);
    });

    test('Score is correct percentage', () {
      final service = ScoreService();
      final score = service.calculateScore(completedDays: 3, targetDays: 6);
      expect(score, 50);
    });

    test('Score does not exceed 100', () {
      final service = ScoreService();
      final score = service.calculateScore(completedDays: 10, targetDays: 5);
      expect(score <= 100, true);
    });
  });

  // ================= STREAK TESTS =================
  group('StreakService Tests', () {
    test('Streak is 0 for empty list', () {
      final service = StreakService();
      final streak = service.calculateStreak([]);
      expect(streak, 0);
    });

    test('Streak is 1 for single date', () {
      final service = StreakService();
      final streak = service.calculateStreak([DateTime.now()]);
      expect(streak, 1);
    });

    test('Streak counts consecutive days correctly', () {
      final service = StreakService();
      final now = DateTime.now();

      final dates = [
        now,
        now.subtract(const Duration(days: 1)),
        now.subtract(const Duration(days: 2)),
      ];

      final streak = service.calculateStreak(dates);
      expect(streak, 3);
    });

    test('Streak breaks when gap exists', () {
      final service = StreakService();
      final now = DateTime.now();

      final dates = [
        now,
        now.subtract(const Duration(days: 2)),
      ];

      final streak = service.calculateStreak(dates);
      expect(streak, 1);
    });
  });

  // ================= AI BUDDY TESTS =================
  group('AIBuddyService Tests', () {
    test('Returns high streak message', () {
      final service = AIBuddyService();
      final message = service.getMessage(7, 50);
      expect(message.contains('unstoppable'), true);
    });

    test('Returns high score message', () {
      final service = AIBuddyService();
      final message = service.getMessage(3, 80);
      expect(message.contains('Great consistency'), true);
    });

    test('Returns medium score message', () {
      final service = AIBuddyService();
      final message = service.getMessage(2, 50);
      expect(message.contains('improving'), true);
    });

    test('Returns low score message', () {
      final service = AIBuddyService();
      final message = service.getMessage(0, 10);
      expect(message.contains('Start small'), true);
    });
  });

}
