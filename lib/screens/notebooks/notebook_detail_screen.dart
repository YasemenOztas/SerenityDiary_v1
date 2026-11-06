import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:serenity_diary/models/notebook.dart';
import 'package:serenity_diary/models/notebook_note.dart';
import 'package:serenity_diary/repository/notebook_repository.dart';
import 'package:serenity_diary/screens/notebooks/add_notebook_note_screen.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

class NotebookDetailScreen extends StatefulWidget {
  final Notebook notebook;
  const NotebookDetailScreen({super.key, required this.notebook});

  @override
  State<NotebookDetailScreen> createState() => _NotebookDetailScreenState();
}

class _NotebookDetailScreenState extends State<NotebookDetailScreen> {
  List<NotebookNote> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes =
        await NotebookRepository.getNotes(widget.notebook.id!);
    if (mounted) {
      setState(() {
        _notes = notes;
        _loading = false;
      });
    }
  }

  Future<void> _deleteNote(NotebookNote note) async {
    await NotebookRepository.deleteNote(note.id!);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final nb = widget.notebook;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6B7D58),
              FairyTheme.bgSage,
              Color(0xFF8A9B76),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: FairyTheme.cardSurface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: FairyTheme.gold.withOpacity(0.4)),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16, color: FairyTheme.inkBrown),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(nb.emoji,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text(nb.name,
                            style: GoogleFonts.dancingScript(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: FairyTheme.cream)),
                      ],
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // Notes list
              Expanded(
                child: _loading
                    ? Center(child: CircularProgressIndicator())
                    : _notes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(nb.emoji,
                                    style:
                                        const TextStyle(fontSize: 48)),
                                const SizedBox(height: 12),
                                Text('Bu defterde henüz not yok',
                                    style: GoogleFonts.playfairDisplay(
                                        fontSize: 16,
                                        color: FairyTheme.cream,
                                        fontStyle: FontStyle.italic)),
                                const SizedBox(height: 6),
                                Text('İlk notu eklemek için + butonuna bas',
                                    style: GoogleFonts.nunito(
                                        fontSize: 13,
                                        color: FairyTheme.cream
                                            .withOpacity(0.7))),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: _notes.length,
                            itemBuilder: (context, i) {
                              final note = _notes[i];
                              return _NoteItem(
                                note: note,
                                notebook: nb,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AddNotebookNoteScreen(
                                        notebook: nb,
                                        note: note,
                                      ),
                                    ),
                                  );
                                  _loadNotes();
                                },
                                onDelete: () => _deleteNote(note),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),

      // FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AddNotebookNoteScreen(notebook: nb),
            ),
          );
          _loadNotes();
        },
        backgroundColor: FairyTheme.gold,
        foregroundColor: FairyTheme.cream,
        elevation: 6,
        shape: const CircleBorder(),
        child: Icon(Icons.edit_note_rounded, size: 28),
      ),
    );
  }
}

class _NoteItem extends StatelessWidget {
  final NotebookNote note;
  final Notebook notebook;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NoteItem({
    required this.note,
    required this.notebook,
    required this.onTap,
    required this.onDelete,
  });

  static const _rotations = [-0.01, 0.008, -0.005, 0.012, -0.007];

  @override
  Widget build(BuildContext context) {
    final rot = _rotations[
        note.id != null ? note.id! % _rotations.length : 0];

    return GestureDetector(
      onTap: onTap,
      child: Transform.rotate(
        angle: rot,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FairyTheme.cream,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: notebook.color.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: FairyTheme.inkBrown.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title and Delete Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: FairyTheme.inkBrown,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: FairyTheme.berryPink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.close_rounded,
                          size: 16, color: FairyTheme.berryPink.withOpacity(0.7)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Custom subtle divider
              Container(
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      notebook.color.withOpacity(0.6),
                      notebook.color.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Body
              Text(
                note.description,
                style: GoogleFonts.nunito(
                  color: FairyTheme.medBrown,
                  fontSize: 14,
                  height: 1.5,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Footer: Subtle date and emoji
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('d MMMM yyyy', 'tr').format(note.createdAt),
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: FairyTheme.lightBrown.withOpacity(0.8),
                    ),
                  ),
                  Text(notebook.emoji, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
