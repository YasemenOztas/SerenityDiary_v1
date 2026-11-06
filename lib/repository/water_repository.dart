import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:serenity_diary/models/water_entry.dart';

class WaterRepository {
  static const _dbName = 'water-database.db';
  static const _tableName = 'water_entries';

  static Future<Database> _database() async {
    return openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) => db.execute(
        'CREATE TABLE $_tableName('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'amountMl INTEGER, '
        'createdAt TEXT'
        ')',
      ),
      version: 1,
    );
  }

  static Future<int> insert(WaterEntry entry) async {
    final db = await _database();
    return db.insert(_tableName, entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> delete(int id) async {
    final db = await _database();
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  /// Returns entries for [date], ordered newest first.
  static Future<List<WaterEntry>> getEntriesForDate(DateTime date) async {
    final db = await _database();
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final maps = await db.query(
      _tableName,
      where: 'createdAt >= ? AND createdAt <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'createdAt DESC',
    );
    return maps
        .map((m) => WaterEntry(
              id: m['id'] as int,
              amountMl: m['amountMl'] as int,
              createdAt: DateTime.parse(m['createdAt'] as String),
            ))
        .toList();
  }

  /// Returns all entries ordered newest first.
  static Future<List<WaterEntry>> getAllEntries() async {
    final db = await _database();
    final maps =
        await db.query(_tableName, orderBy: 'createdAt DESC');
    return maps
        .map((m) => WaterEntry(
              id: m['id'] as int,
              amountMl: m['amountMl'] as int,
              createdAt: DateTime.parse(m['createdAt'] as String),
            ))
        .toList();
  }

  /// Returns total ml per day for the last [days] days.
  /// Key format: 'YYYY-MM-DD'
  static Future<Map<String, int>> getDailyTotals({int days = 7}) async {
    final db = await _database();
    final result = <String, int>{};
    final now = DateTime.now();
    for (int i = days - 1; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      final end = DateTime(day.year, day.month, day.day, 23, 59, 59);
      final key =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final rows = await db.query(
        _tableName,
        where: 'createdAt >= ? AND createdAt <= ?',
        whereArgs: [day.toIso8601String(), end.toIso8601String()],
      );
      result[key] =
          rows.fold<int>(0, (sum, r) => sum + (r['amountMl'] as int));
    }
    return result;
  }

  /// Returns total ml per day for a specific month.
  /// Key format: 'YYYY-MM-DD'
  static Future<Map<String, int>> getDailyTotalsForMonth(int year, int month) async {
    final db = await _database();
    final result = <String, int>{};
    
    final monthStr = month.toString().padLeft(2, '0');
    final rows = await db.query(
      _tableName,
      where: 'createdAt LIKE ?',
      whereArgs: ['$year-$monthStr-%'],
    );

    for (var r in rows) {
      final dateStr = (r['createdAt'] as String).substring(0, 10);
      final amount = r['amountMl'] as int;
      result[dateStr] = (result[dateStr] ?? 0) + amount;
    }
    
    return result;
  }
}
