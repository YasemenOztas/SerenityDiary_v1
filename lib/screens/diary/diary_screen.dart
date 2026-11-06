import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:serenity_diary/providers/notes/notes_provider.dart';
import 'package:serenity_diary/screens/diary/add-note/add_note_screen.dart';
import 'package:serenity_diary/screens/diary/widgets/item_note.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
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
              // ── AppBar ─────────────────────────────────────────
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
                    // Title
                    Row(
                      children: [
                        Text('🪶', style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          'Günlüğüm',
                          style: GoogleFonts.dancingScript(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: FairyTheme.cream,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Placeholder for symmetry
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // ── Notes list ─────────────────────────────────────
              Expanded(
                child: Consumer<NotesProvider>(
                  builder: (context, provider, _) {
                    if (provider.notes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🌸',
                                style: const TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text(
                              'Henüz bir not girilmedi...',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 16,
                                color: FairyTheme.cream,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'İlk günlük notunu ekle 🪄',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: FairyTheme.cream.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      children: provider.notes
                          .map((e) => ItemNote(note: e))
                          .toList()
                          .reversed
                          .toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // ── FAB ───────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddNoteScreen()),
          );
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
