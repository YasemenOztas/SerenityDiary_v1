import 'package:flutter/foundation.dart';
import 'package:serenity_diary/models/notebook.dart';
import 'package:serenity_diary/repository/notebook_repository.dart';

class NotebooksProvider with ChangeNotifier {
  List<Notebook> _notebooks = [];
  bool _isLoading = true;

  List<Notebook> get notebooks => _notebooks;
  bool get isLoading => _isLoading;

  NotebooksProvider() {
    _load();
  }

  Future<void> _load() async {
    _notebooks = await NotebookRepository.getNotebooks();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNotebook(Notebook nb) async {
    final id = await NotebookRepository.insertNotebook(nb);
    _notebooks.add(Notebook(
      id: id,
      name: nb.name,
      emoji: nb.emoji,
      colorHex: nb.colorHex,
      createdAt: nb.createdAt,
    ));
    notifyListeners();
  }

  Future<void> updateNotebook(Notebook nb) async {
    await NotebookRepository.updateNotebook(nb);
    final idx = _notebooks.indexWhere((n) => n.id == nb.id);
    if (idx != -1) _notebooks[idx] = nb;
    notifyListeners();
  }

  Future<void> deleteNotebook(int id) async {
    await NotebookRepository.deleteNotebook(id);
    _notebooks.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
