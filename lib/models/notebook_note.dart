class NotebookNote {
  int? id;
  int notebookId;
  String title;
  String description;
  DateTime createdAt;

  NotebookNote({
    this.id,
    required this.notebookId,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'notebookId': notebookId,
        'title': title,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
      };

  static NotebookNote fromMap(Map<String, dynamic> m) => NotebookNote(
        id: m['id'] as int,
        notebookId: m['notebookId'] as int,
        title: m['title'] as String,
        description: m['description'] as String,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
}
