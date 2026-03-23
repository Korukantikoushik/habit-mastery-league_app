import 'package:sqflite/sqflite.dart';
import '../../../../core/db/app_database.dart';
import '../models/habit_model.dart';

class HabitLocalDataSource {
  Future<List<HabitModel>> getHabits() async {
    final db = await AppDatabase.instance.database;
    final result = await db.query('habits');

    return result.map((e) => HabitModel.fromMap(e)).toList();
  }

  Future<void> insertHabit(HabitModel habit) async {
    final db = await AppDatabase.instance.database;

    await db.insert(
      'habits',
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteHabit(String id) async {
    final db = await AppDatabase.instance.database;

    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  // 🔥 ADD THIS BELOW

  Future<void> logHabit(String habitId, DateTime date) async {
    final db = await AppDatabase.instance.database;

    await db.insert('habit_logs', {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'habitId': habitId,
      'date': date.toIso8601String(),
    });
  }

  Future<List<DateTime>> getHabitLogs(String habitId) async {
    final db = await AppDatabase.instance.database;

    final result = await db.query(
      'habit_logs',
      where: 'habitId = ?',
      whereArgs: [habitId],
      orderBy: 'date DESC',
    );

    return result.map((e) => DateTime.parse(e['date'] as String)).toList();
  }
}
