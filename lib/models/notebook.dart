import 'package:flutter/material.dart';

class Notebook {
  int? id;
  String name;
  String emoji;
  String colorHex;
  DateTime createdAt;

  Notebook({
    this.id,
    required this.name,
    required this.emoji,
    required this.colorHex,
    required this.createdAt,
  });

  Color get color =>
      Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

  Map<String, dynamic> toMap() => {
        'name': name,
        'emoji': emoji,
        'colorHex': colorHex,
        'createdAt': createdAt.toIso8601String(),
      };

  static Notebook fromMap(Map<String, dynamic> m) => Notebook(
        id: m['id'] as int,
        name: m['name'] as String,
        emoji: m['emoji'] as String,
        colorHex: m['colorHex'] as String,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
}
