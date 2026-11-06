import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:serenity_diary/models/notebook.dart';
import 'package:serenity_diary/models/notebook_note.dart';

class NotebookRepository {
  static const _dbName = 'notebooks.db';

  static Future<Database> _openDb() async {
    return openDatabase(
      join(await getDatabasesPath(), _dbName),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE notebooks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            emoji TEXT,
            colorHex TEXT,
            createdAt TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE notebook_notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            notebookId INTEGER,
            title TEXT,
            description TEXT,
            createdAt TEXT
          )
        ''');
        // Seed 3 default notebooks
        final now = DateTime.now().toIso8601String();
        for (final nb in [
          {'name': 'Yemek Tarifleri', 'emoji': '🍄', 'colorHex': '#BF9B7A'},
          {'name': 'Hobi Fikirleri', 'emoji': '🌿', 'colorHex': '#8FA67A'},
          {'name': 'Genel Notlar', 'emoji': '📋', 'colorHex': '#B8A8C8'},
        ]) {
          await db.insert('notebooks',
              {...nb, 'createdAt': now});
        }
      },
    );
  }

  // ── Notebooks ────────────────────────────────────────────────

  static Future<List<Notebook>> getNotebooks() async {
    final db = await _openDb();
    final rows = await db.query('notebooks', orderBy: 'createdAt ASC');
    return rows.map(Notebook.fromMap).toList();
  }

  static Future<int> insertNotebook(Notebook nb) async {
    final db = await _openDb();
    return db.insert('notebooks', nb.toMap());
  }

  static Future<void> updateNotebook(Notebook nb) async {
    final db = await _openDb();
    await db.update('notebooks', nb.toMap(),
        where: 'id = ?', whereArgs: [nb.id]);
  }

  static Future<void> deleteNotebook(int id) async {
    final db = await _openDb();
    await db.delete('notebooks', where: 'id = ?', whereArgs: [id]);
    // Cascade delete notes
    await db.delete('notebook_notes',
        where: 'notebookId = ?', whereArgs: [id]);
  }

  // ── Notebook notes ───────────────────────────────────────────

  static Future<List<NotebookNote>> getNotes(int notebookId) async {
    final db = await _openDb();
    final rows = await db.query(
      'notebook_notes',
      where: 'notebookId = ?',
      whereArgs: [notebookId],
      orderBy: 'createdAt DESC',
    );
    return rows.map(NotebookNote.fromMap).toList();
  }

  static Future<int> insertNote(NotebookNote note) async {
    final db = await _openDb();
    return db.insert('notebook_notes', note.toMap());
  }

  static Future<void> updateNote(NotebookNote note) async {
    final db = await _openDb();
    await db.update('notebook_notes', note.toMap(),
        where: 'id = ?', whereArgs: [note.id]);
  }

  static Future<void> deleteNote(int id) async {
    final db = await _openDb();
    await db.delete('notebook_notes', where: 'id = ?', whereArgs: [id]);
  }
}
