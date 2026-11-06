import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serenity_diary/models/notebook.dart';
import 'package:serenity_diary/models/notebook_note.dart';
import 'package:serenity_diary/repository/notebook_repository.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

class AddNotebookNoteScreen extends StatefulWidget {
  final Notebook notebook;
  final NotebookNote? note;
  const AddNotebookNoteScreen(
      {super.key, required this.notebook, this.note});

  @override
  State<AddNotebookNoteScreen> createState() =>
      _AddNotebookNoteScreenState();
}

class _AddNotebookNoteScreenState
    extends State<AddNotebookNoteScreen> {
  late final TextEditingController _title;
  late final TextEditingController _desc;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.note?.title ?? '');
    _desc =
        TextEditingController(text: widget.note?.description ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title =
        _title.text.trim().isEmpty ? 'İsimsiz Not' : _title.text.trim();
    if (widget.note == null) {
      await NotebookRepository.insertNote(NotebookNote(
        notebookId: widget.notebook.id!,
        title: title,
        description: _desc.text,
        createdAt: DateTime.now(),
      ));
    } else {
      await NotebookRepository.updateNote(NotebookNote(
        id: widget.note!.id,
        notebookId: widget.notebook.id!,
        title: title,
        description: _desc.text,
        createdAt: widget.note!.createdAt,
      ));
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    await NotebookRepository.deleteNote(widget.note!.id!);
    if (mounted) Navigator.pop(context);
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FairyTheme.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: FairyTheme.gold.withOpacity(0.4)),
        ),
        title: Text('🗑️ Notu Sil',
            style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: FairyTheme.inkBrown)),
        content: Text('Bu notu silmek istediğine emin misin?',
            style: GoogleFonts.nunito(color: FairyTheme.medBrown)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Hayır',
                style:
                    GoogleFonts.nunito(color: FairyTheme.lightBrown)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _delete();
            },
            child: Text('Evet, Sil',
                style: GoogleFonts.nunito(
                    color: FairyTheme.berryPink,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
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
                    Text(
                      widget.note == null
                          ? '${nb.emoji} Yeni Not'
                          : '${nb.emoji} Düzenle',
                      style: GoogleFonts.dancingScript(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: FairyTheme.cream),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (widget.note != null) ...[
                          GestureDetector(
                            onTap: _showDeleteDialog,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    FairyTheme.dustyRose.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: FairyTheme.berryPink
                                        .withOpacity(0.4)),
                              ),
                              child: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: FairyTheme.berryPink),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        GestureDetector(
                          onTap: _save,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: FairyTheme.gold,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: FairyTheme.goldDark
                                      .withOpacity(0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(Icons.check_rounded,
                                size: 18, color: FairyTheme.cream),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Writing area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  decoration: BoxDecoration(
                    color: FairyTheme.cream,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: nb.color.withOpacity(0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: FairyTheme.inkBrown.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Top accent with notebook color
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: nb.color.withOpacity(0.4),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(19),
                            topRight: Radius.circular(19),
                          ),
                        ),
                      ),
                      // Title
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: TextField(
                          controller: _title,
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: FairyTheme.inkBrown),
                          decoration: InputDecoration(
                            hintText: 'Başlık...',
                            hintStyle: GoogleFonts.playfairDisplay(
                                fontSize: 20,
                                color:
                                    FairyTheme.lightBrown.withOpacity(0.5),
                                fontStyle: FontStyle.italic),
                            border: InputBorder.none,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(nb.emoji,
                                  style: const TextStyle(fontSize: 20)),
                            ),
                            prefixIconConstraints:
                                const BoxConstraints(minWidth: 0),
                          ),
                        ),
                      ),
                      // Divider
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                nb.color.withOpacity(0.0),
                                nb.color.withOpacity(0.5),
                                nb.color.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Body
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20, 8, 20, 16),
                          child: TextField(
                            controller: _desc,
                            style: GoogleFonts.nunito(
                                fontSize: 15,
                                color: FairyTheme.medBrown,
                                height: 1.7),
                            decoration: InputDecoration(
                              hintText: 'Yazmaya başla...',
                              hintStyle: GoogleFonts.nunito(
                                  fontSize: 15,
                                  color: FairyTheme.lightBrown
                                      .withOpacity(0.5),
                                  fontStyle: FontStyle.italic),
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
