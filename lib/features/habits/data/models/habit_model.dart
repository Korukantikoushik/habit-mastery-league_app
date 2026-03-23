import '../../domain/entities/habit.dart';

class HabitModel extends Habit {
  HabitModel({
    required super.id,
    required super.title,
    required super.description,
    required super.targetDays,
    required super.createdAt,
  });

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      targetDays: map['targetDays'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetDays': targetDays,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
