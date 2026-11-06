class WaterEntry {
  int? id;
  int amountMl;
  DateTime createdAt;

  WaterEntry({
    this.id,
    required this.amountMl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'amountMl': amountMl,
        'createdAt': createdAt.toIso8601String(),
      };
}
