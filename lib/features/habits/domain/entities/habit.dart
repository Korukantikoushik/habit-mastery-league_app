class Habit {
  final String id;
  final String title;
  final String description;
  final int targetDays;
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.targetDays,
    required this.createdAt,
  });

  Habit copyWith({String? title, String? description, int? targetDays}) {
    return Habit(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDays: targetDays ?? this.targetDays,
      createdAt: createdAt,
    );
  }
}
