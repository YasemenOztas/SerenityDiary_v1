import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:serenity_diary/models/note.dart';
import 'package:serenity_diary/providers/notes/notes_provider.dart';
import 'package:serenity_diary/providers/preferences_provider.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? note;
  const AddNoteScreen({super.key, this.note});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();

  @override
  void initState() {
    if (widget.note != null) {
      _title.text = widget.note!.title;
      _description.text = widget.note!.description;
    }
    super.initState();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              // ── Custom AppBar ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Back button
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
                    // Title
                    Text(
                      widget.note == null ? '✨ Yeni Not' : '🖊️ Düzenle',
                      style: GoogleFonts.dancingScript(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: FairyTheme.cream,
                      ),
                    ),
                    const Spacer(),
                    // Actions
                    Row(
                      children: [
                        if (widget.note != null)
                          GestureDetector(
                            onTap: _showDeleteDialog,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: FairyTheme.dustyRose.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: FairyTheme.berryPink
                                        .withOpacity(0.4)),
                              ),
                              child: Icon(Icons.delete_outline_rounded,
                                  size: 18, color: FairyTheme.berryPink),
                            ),
                          ),
                        if (widget.note != null) const SizedBox(width: 8),
                        // Save button
                        GestureDetector(
                          onTap: () {
                            if (widget.note == null) {
                              _insertNote();
                            } else {
                              _updateNote();
                            }
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: FairyTheme.gold,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      FairyTheme.goldDark.withOpacity(0.4),
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

              // ── Writing area ──────────────────────────────────
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  decoration: BoxDecoration(
                    color: FairyTheme.cream,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: FairyTheme.gold.withOpacity(0.4),
                        width: 1.5),
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
                      // Book spine top decoration
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: FairyTheme.parchmentDark.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(19),
                            topRight: Radius.circular(19),
                          ),
                        ),
                      ),
                      // Title field
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: TextField(
                          controller: _title,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: FairyTheme.inkBrown,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Başlık...',
                            hintStyle: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              color: FairyTheme.lightBrown.withOpacity(0.5),
                              fontStyle: FontStyle.italic,
                            ),
                            border: InputBorder.none,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text('🪶',
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
                                FairyTheme.gold.withOpacity(0.0),
                                FairyTheme.gold.withOpacity(0.4),
                                FairyTheme.gold.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Description field
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20, 8, 20, 16),
                          child: TextField(
                            controller: _description,
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              color: FairyTheme.medBrown,
                              height: 1.7,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Bugün nasıl hissediyorsun? Buraya yazmaya başla...',
                              hintStyle: GoogleFonts.nunito(
                                fontSize: 15,
                                color:
                                    FairyTheme.lightBrown.withOpacity(0.5),
                                fontStyle: FontStyle.italic,
                              ),
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

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FairyTheme.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: FairyTheme.gold.withOpacity(0.4)),
        ),
        title: Text(
          '🗑️ Notu Sil',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: FairyTheme.inkBrown,
          ),
        ),
        content: Text(
          'Bu notu silmek istediğine emin misin?',
          style: GoogleFonts.nunito(color: FairyTheme.medBrown),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Hayır',
                style: GoogleFonts.nunito(color: FairyTheme.medBrown)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteNote();
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

  void _insertNote() {
    final note = Note(
      title: _title.text.isEmpty ? 'İsimsiz Not' : _title.text,
      description: _description.text,
      createdAt: DateTime.now(),
    );
    Provider.of<NotesProvider>(context, listen: false).insert(note: note);
    
    // Add Pixie Dust
    Provider.of<PreferencesProvider>(context, listen: false).addPixieDust(10);
    
    // Show SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✨ 10 Sihir Tozu kazandın!'),
        backgroundColor: FairyTheme.goldDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _updateNote() {
    final note = Note(
      id: widget.note!.id!,
      title: _title.text.isEmpty ? 'İsimsiz Not' : _title.text,
      description: _description.text,
      createdAt: widget.note!.createdAt,
    );
    Provider.of<NotesProvider>(context, listen: false).update(note: note);
  }

  void _deleteNote() {
    Provider.of<NotesProvider>(context, listen: false)
        .delete(note: widget.note!)
        .then((_) async {
      final prefs = Provider.of<PreferencesProvider>(context, listen: false);
      await prefs.removePixieDust(10);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('⚠️ Not silindiği için 10 Sihir Tozu geri alındı.'),
            backgroundColor: FairyTheme.dustyRose,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context);
      }
    });
  }
}
