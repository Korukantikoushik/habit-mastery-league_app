import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/ai_buddy_service.dart';
import '../../../../core/services/score_service.dart';
import '../../../../core/services/streak_service.dart';
import '../../data/datasources/habit_local_data_source.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../domain/entities/habit.dart';

final habitRepositoryProvider = Provider<HabitRepositoryImpl>((ref) {
  return HabitRepositoryImpl(HabitLocalDataSource());
});

final streakServiceProvider = Provider<StreakService>((ref) {
  return StreakService();
});

final scoreServiceProvider = Provider<ScoreService>((ref) {
  return ScoreService();
});

final aiBuddyProvider = Provider<AIBuddyService>((ref) {
  return AIBuddyService();
});

final habitProvider = StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  final repo = ref.watch(habitRepositoryProvider);
  final streakService = ref.watch(streakServiceProvider);
  final scoreService = ref.watch(scoreServiceProvider);
  final aiBuddy = ref.watch(aiBuddyProvider);

  return HabitNotifier(repo, streakService, scoreService, aiBuddy);
});

class HabitNotifier extends StateNotifier<List<Habit>> {
  final HabitRepositoryImpl repository;
  final StreakService streakService;
  final ScoreService scoreService;
  final AIBuddyService aiBuddy;

  int _xp = 0;
  int _level = 1;

  HabitNotifier(
    this.repository,
    this.streakService,
    this.scoreService,
    this.aiBuddy,
  ) : super([]) {
    loadHabits();
  }

  int getXP() => _xp;
  int getLevel() => _level;

  Future<void> loadHabits() async {
    try {
      final habits = await repository.getHabits();

      if (habits.isEmpty) {
        await _createDefaultHabits();
        final newHabits = await repository.getHabits();
        state = [...newHabits];
      } else {
        state = [...habits];
      }
    } catch (e) {
      debugPrint('loadHabits error: $e');
    }
  }

  Future<void> _createDefaultHabits() async {
    final now = DateTime.now();

    final defaultHabits = [
      Habit(
        id: const Uuid().v4(),
        title: 'Workout',
        description: 'Daily physical activity',
        targetDays: 30,
        createdAt: now,
      ),
      Habit(
        id: const Uuid().v4(),
        title: 'Reading',
        description: 'Read 10 pages daily',
        targetDays: 30,
        createdAt: now,
      ),
      Habit(
        id: const Uuid().v4(),
        title: 'Meditation',
        description: '10 min mindfulness',
        targetDays: 30,
        createdAt: now,
      ),
    ];

    for (final habit in defaultHabits) {
      await repository.addHabit(habit);
    }
  }

  Future<void> addCustomHabit({
    required String title,
    required String description,
  }) async {
    try {
      final now = DateTime.now();

      final habit = Habit(
        id: const Uuid().v4(),
        title: title,
        description: description,
        targetDays: 30,
        createdAt: now,
      );

      await repository.addHabit(habit);

      final habits = await repository.getHabits();
      state = [...habits];
    } catch (e) {
      debugPrint('addCustomHabit error: $e');
    }
  }

  Future<void> addWorkoutHabit() async {
    await addCustomHabit(
      title: 'Workout',
      description: 'Daily physical activity',
    );
  }

  Future<void> addReadingHabit() async {
    await addCustomHabit(title: 'Reading', description: 'Read 10 pages daily');
  }

  Future<void> addMeditationHabit() async {
    await addCustomHabit(
      title: 'Meditation',
      description: '10 min mindfulness',
    );
  }

  Future<void> updateHabit(String id, String title, String description) async {
    try {
      final existingHabits = await repository.getHabits();
      final oldHabit = existingHabits.firstWhere((habit) => habit.id == id);

      final updatedHabit = Habit(
        id: oldHabit.id,
        title: title,
        description: description,
        targetDays: oldHabit.targetDays,
        createdAt: oldHabit.createdAt,
      );

      await repository.deleteHabit(id);
      await repository.addHabit(updatedHabit);

      final habits = await repository.getHabits();
      state = [...habits];
    } catch (e) {
      debugPrint('updateHabit error: $e');
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      await repository.deleteHabit(id);

      final habits = await repository.getHabits();
      state = [...habits];
    } catch (e) {
      debugPrint('deleteHabit error: $e');
    }
  }

  Future<void> completeHabit(String habitId) async {
    try {
      final logs = await repository.getLogs(habitId);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final alreadyDoneToday = logs.any((log) {
        final logDay = DateTime(log.year, log.month, log.day);
        return logDay == today;
      });

      if (alreadyDoneToday) return;

      await repository.logHabit(habitId);

      _xp += 10;
      if (_xp >= _level * 50) {
        _level++;
      }

      final habits = await repository.getHabits();
      state = [...habits];
    } catch (e) {
      debugPrint('completeHabit error: $e');
    }
  }

  Future<int> getStreakForHabit(String habitId) async {
    try {
      final logs = await repository.getLogs(habitId);
      return streakService.calculateStreak(logs);
    } catch (e) {
      debugPrint('getStreakForHabit error: $e');
      return 0;
    }
  }

  Future<double> getScoreForHabit(String habitId) async {
    try {
      final logs = await repository.getLogs(habitId);
      return scoreService.calculateScore(
        completedDays: logs.length,
        targetDays: 7,
      );
    } catch (e) {
      debugPrint('getScoreForHabit error: $e');
      return 0;
    }
  }

  Future<List<DateTime>> getLogsForHabit(String habitId) async {
    try {
      return await repository.getLogs(habitId);
    } catch (e) {
      debugPrint('getLogsForHabit error: $e');
      return [];
    }
  }

  Future<String> getMessage() async {
    try {
      if (state.isEmpty) {
        return aiBuddy.getMessage(0, 0);
      }

      final firstHabitId = state.first.id;
      final streak = await getStreakForHabit(firstHabitId);
      final score = await getScoreForHabit(firstHabitId);

      return aiBuddy.getMessage(streak, score);
    } catch (e) {
      debugPrint('getMessage error: $e');
      return aiBuddy.getMessage(0, 0);
    }
  }

  Future<List<int>> getWeeklyData() async {
    try {
      final weekly = List<int>.filled(7, 0);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (final habit in state) {
        final logs = await repository.getLogs(habit.id);

        for (final log in logs) {
          final logDate = DateTime(log.year, log.month, log.day);
          final difference = today.difference(logDate).inDays;

          if (difference >= 0 && difference < 7) {
            final index = logDate.weekday - 1;
            weekly[index] += 1;
          }
        }
      }

      return weekly;
    } catch (e) {
      debugPrint('getWeeklyData error: $e');
      return List<int>.filled(7, 0);
    }
  }

  Future<List<Map<String, dynamic>>> exportHabitsAsJsonData() async {
    try {
      final habits = await repository.getHabits();

      return habits
          .map(
            (habit) => {
              'id': habit.id,
              'title': habit.title,
              'description': habit.description,
              'targetDays': habit.targetDays,
              'createdAt': habit.createdAt.toIso8601String(),
            },
          )
          .toList();
    } catch (e) {
      debugPrint('exportHabitsAsJsonData error: $e');
      return [];
    }
  }
}
