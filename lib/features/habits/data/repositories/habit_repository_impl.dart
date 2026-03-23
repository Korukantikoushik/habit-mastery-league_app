import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/habit_local_data_source.dart';
import '../models/habit_model.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalDataSource localDataSource;

  HabitRepositoryImpl(this.localDataSource);

  @override
  Future<void> addHabit(Habit habit) async {
    final model = HabitModel(
      id: habit.id,
      title: habit.title,
      description: habit.description,
      targetDays: habit.targetDays,
      createdAt: habit.createdAt,
    );

    await localDataSource.insertHabit(model);
  }

  @override
  Future<void> deleteHabit(String id) async {
    await localDataSource.deleteHabit(id);
  }

  @override
  Future<List<Habit>> getHabits() async {
    return await localDataSource.getHabits();
  }

  // 🔥 ADD THESE BELOW

  Future<void> logHabit(String habitId) async {
    await localDataSource.logHabit(habitId, DateTime.now());
  }

  Future<List<DateTime>> getLogs(String habitId) async {
    return await localDataSource.getHabitLogs(habitId);
  }
}
