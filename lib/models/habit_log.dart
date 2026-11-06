class HabitLog {
  int? id;
  int habitId;
  String date; // Format: YYYY-MM-DD
  bool isCompleted;

  HabitLog({
    this.id,
    required this.habitId,
    required this.date,
    this.isCompleted = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'habitId': habitId,
      'date': date,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  static HabitLog fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['id'] as int,
      habitId: map['habitId'] as int,
      date: map['date'] as String,
      isCompleted: (map['isCompleted'] as int) == 1,
    );
  }
}
