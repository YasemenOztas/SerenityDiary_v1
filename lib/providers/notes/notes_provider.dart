import 'package:flutter/material.dart';
import 'package:serenity_diary/models/note.dart';
import 'package:serenity_diary/repository/note_repository.dart';

class NotesProvider with ChangeNotifier {
  List<Note> notes = [];

  NotesProvider() {
    getNotes();
  }

  getNotes() async {
    notes = await NoteRepository.getNotes();
    notifyListeners();
  }

  insert({required Note note}) async {
    await NoteRepository.insert(note: note);
    getNotes();
  }

  update({required Note note}) async {
    await NoteRepository.update(note: note);
    getNotes();
  }

  Future<bool> delete({required Note note}) async {
    await NoteRepository.delete(note: note);
    getNotes();
    return true;
  }
}
