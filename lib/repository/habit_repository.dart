import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:serenity_diary/models/habit.dart';
import 'package:serenity_diary/models/habit_log.dart';

class HabitRepository {
  static const _dbName = 'habits.db';

  static Future<Database> _openDb() async {
    return openDatabase(
      join(await getDatabasesPath(), _dbName),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE habits(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            selectedDays TEXT,
            createdAt TEXT,
            isArchived INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE habit_logs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            habitId INTEGER,
            date TEXT,
            isCompleted INTEGER DEFAULT 0,
            FOREIGN KEY (habitId) REFERENCES habits(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // ── Habits ────────────────────────────────────────────────

  static Future<List<Habit>> getActiveHabits() async {
    final db = await _openDb();
    final rows = await db.query(
      'habits',
      where: 'isArchived = ?',
      whereArgs: [0],
      orderBy: 'createdAt ASC',
    );
    return rows.map(Habit.fromMap).toList();
  }

  static Future<List<Habit>> getArchivedHabits() async {
    final db = await _openDb();
    final rows = await db.query(
      'habits',
      where: 'isArchived = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
    return rows.map(Habit.fromMap).toList();
  }

  static Future<List<Habit>> getAllHabits() async {
    final db = await _openDb();
    final rows = await db.query('habits', orderBy: 'createdAt ASC');
    return rows.map(Habit.fromMap).toList();
  }

  static Future<int> insertHabit(Habit habit) async {
    final db = await _openDb();
    return db.insert('habits', habit.toMap());
  }

  static Future<void> updateHabit(Habit habit) async {
    final db = await _openDb();
    await db.update('habits', habit.toMap(),
        where: 'id = ?', whereArgs: [habit.id]);
  }

  static Future<void> deleteHabit(int id) async {
    final db = await _openDb();
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
    await db.delete('habit_logs', where: 'habitId = ?', whereArgs: [id]);
  }

  static Future<void> archiveHabit(int id) async {
    final db = await _openDb();
    await db.update('habits', {'isArchived': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> unarchiveHabit(int id) async {
    final db = await _openDb();
    await db.update('habits', {'isArchived': 0},
        where: 'id = ?', whereArgs: [id]);
  }

  // ── Habit Logs ───────────────────────────────────────────

  static Future<List<HabitLog>> getLogsForDate(String date) async {
    final db = await _openDb();
    final rows = await db.query(
      'habit_logs',
      where: 'date = ?',
      whereArgs: [date],
    );
    return rows.map(HabitLog.fromMap).toList();
  }

  static Future<HabitLog?> getLog(int habitId, String date) async {
    final db = await _openDb();
    final rows = await db.query(
      'habit_logs',
      where: 'habitId = ? AND date = ?',
      whereArgs: [habitId, date],
    );
    if (rows.isNotEmpty) {
      return HabitLog.fromMap(rows.first);
    }
    return null;
  }

  static Future<void> toggleLog(int habitId, String date, bool isCompleted) async {
    final db = await _openDb();
    final existing = await getLog(habitId, date);
    
    if (existing == null) {
      if (isCompleted) {
        await db.insert('habit_logs', {
          'habitId': habitId,
          'date': date,
          'isCompleted': 1,
        });
      }
    } else {
      if (isCompleted) {
        await db.update('habit_logs', {'isCompleted': 1},
            where: 'id = ?', whereArgs: [existing.id]);
      } else {
        // If unchecking, we can just delete the log or set it to 0. Deleting is cleaner.
        await db.delete('habit_logs', where: 'id = ?', whereArgs: [existing.id]);
      }
    }
  }

  // Gets streak for a specific habit
  static Future<int> getHabitStreak(int habitId, String todayDateStr) async {
    final db = await _openDb();
    final rows = await db.query(
      'habit_logs',
      where: 'habitId = ? AND isCompleted = 1',
      whereArgs: [habitId],
      orderBy: 'date DESC',
    );
    
    if (rows.isEmpty) return 0;
    
    int streak = 0;
    DateTime current = DateTime.parse(todayDateStr);
    
    // Create a set of completed dates for quick lookup
    Set<String> completedDates = rows.map((r) => r['date'] as String).toSet();
    
    // Check backwards from today (or yesterday if today is not done yet but yesterday is)
    if (completedDates.contains(todayDateStr)) {
      streak++;
      current = current.subtract(const Duration(days: 1));
    } else {
      // If today is not done, check if yesterday was done. If so, streak is active.
      String yesterdayStr = current.subtract(const Duration(days: 1)).toIso8601String().split('T')[0];
      if (completedDates.contains(yesterdayStr)) {
         current = current.subtract(const Duration(days: 1));
      } else {
         return 0; // neither today nor yesterday done, streak is 0
      }
    }

    // Now go backwards continuously
    while (true) {
      String checkDate = current.toIso8601String().split('T')[0];
      if (completedDates.contains(checkDate)) {
        streak++;
        current = current.subtract(const Duration(days: 1));
      } else {
        break; // streak broken
      }
    }
    
    return streak;
  }

  static Future<Map<String, dynamic>> getDetailedStats(Habit habit, String todayDateStr) async {
    final db = await _openDb();
    final rows = await db.query(
      'habit_logs',
      where: 'habitId = ? AND isCompleted = 1',
      whereArgs: [habit.id],
      orderBy: 'date ASC',
    );
    
    int totalCompleted = rows.length;
    
    // Calculate Longest Streak
    int longestStreak = 0;
    int currentRun = 0;
    
    if (rows.isNotEmpty) {
      Set<String> completedDates = rows.map((r) => r['date'] as String).toSet();
      DateTime start = habit.createdAt;
      DateTime today = DateTime.parse(todayDateStr);
      
      // Iterate from creation date to today
      DateTime iter = DateTime(start.year, start.month, start.day);
      while (!iter.isAfter(today)) {
        String iterStr = iter.toIso8601String().substring(0, 10);
        if (completedDates.contains(iterStr)) {
          currentRun++;
          if (currentRun > longestStreak) {
            longestStreak = currentRun;
          }
        } else {
          currentRun = 0;
        }
        iter = iter.add(const Duration(days: 1));
      }
    }
    
    // Calculate Total Missed
    int totalScheduled = 0;
    DateTime start = habit.createdAt;
    DateTime today = DateTime.parse(todayDateStr);
    DateTime iter = DateTime(start.year, start.month, start.day);
    
    while (!iter.isAfter(today)) {
      if (habit.selectedDays.contains(iter.weekday)) {
        totalScheduled++;
      }
      iter = iter.add(const Duration(days: 1));
    }
    
    int totalMissed = totalScheduled - totalCompleted;
    if (totalMissed < 0) totalMissed = 0; // Just in case they logged on unscheduled days
    
    final currentStreak = await getHabitStreak(habit.id!, todayDateStr);

    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalCompleted': totalCompleted,
      'totalMissed': totalMissed,
    };
  }

  static Future<Map<String, bool>> getHabitStatusForMonth(int year, int month) async {
    final db = await _openDb();
    final result = <String, bool>{};
    
    final habits = await getAllHabits();
    if (habits.isEmpty) return result;

    final monthStr = month.toString().padLeft(2, '0');
    final logs = await db.query(
      'habit_logs',
      where: 'date LIKE ? AND isCompleted = 1',
      whereArgs: ['$year-$monthStr-%'],
    );

    // Group logs by date
    final logsByDate = <String, Set<int>>{};
    for (var row in logs) {
      final dateStr = row['date'] as String;
      final habitId = row['habitId'] as int;
      logsByDate.putIfAbsent(dateStr, () => {}).add(habitId);
    }

    // Iterate through all days of the month
    final lastDay = DateTime(year, month + 1, 0).day;
    for (int day = 1; day <= lastDay; day++) {
      final currentDay = DateTime(year, month, day);
      final dateStr = currentDay.toIso8601String().substring(0, 10);
      
      // If day is in the future, don't calculate status as "complete" or "missed"
      if (currentDay.isAfter(DateTime.now())) continue;

      int scheduledCount = 0;
      int completedCount = 0;
      final completedHabitsForDay = logsByDate[dateStr] ?? {};

      for (var habit in habits) {
        // Was the habit created on or before this day?
        final createdDate = DateTime(habit.createdAt.year, habit.createdAt.month, habit.createdAt.day);
        if (!createdDate.isAfter(currentDay)) {
          // Is it scheduled for this weekday?
          if (habit.selectedDays.contains(currentDay.weekday)) {
            scheduledCount++;
            if (completedHabitsForDay.contains(habit.id)) {
              completedCount++;
            }
          }
        }
      }

      // If there were habits scheduled, did they complete all of them?
      if (scheduledCount > 0) {
        result[dateStr] = (scheduledCount == completedCount);
      }
    }

    return result;
  }
}
