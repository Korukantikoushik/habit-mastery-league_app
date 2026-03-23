class HabitLogModel {
  final String id;
  final String habitId;
  final DateTime date;

  HabitLogModel({required this.id, required this.habitId, required this.date});

  Map<String, dynamic> toMap() {
    return {'id': id, 'habitId': habitId, 'date': date.toIso8601String()};
  }

  factory HabitLogModel.fromMap(Map<String, dynamic> map) {
    return HabitLogModel(
      id: map['id'],
      habitId: map['habitId'],
      date: DateTime.parse(map['date']),
    );
  }
}
