import 'dart:convert';

class Habit {
  int? id;
  String title;
  List<int> selectedDays; // 1 (Mon) to 7 (Sun)
  DateTime createdAt;
  bool isArchived;

  Habit({
    this.id,
    required this.title,
    required this.selectedDays,
    required this.createdAt,
    this.isArchived = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'selectedDays': jsonEncode(selectedDays),
      'createdAt': createdAt.toIso8601String(),
      'isArchived': isArchived ? 1 : 0,
    };
  }

  static Habit fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as int,
      title: map['title'] as String,
      selectedDays: List<int>.from(jsonDecode(map['selectedDays'] as String)),
      createdAt: DateTime.parse(map['createdAt'] as String),
      isArchived: (map['isArchived'] as int) == 1,
    );
  }
}
