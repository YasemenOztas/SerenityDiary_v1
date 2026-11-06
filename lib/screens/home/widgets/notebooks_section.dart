import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:serenity_diary/models/notebook.dart';
import 'package:serenity_diary/providers/notebooks/notebooks_provider.dart';
import 'package:serenity_diary/screens/notebooks/notebook_detail_screen.dart';
import 'package:serenity_diary/screens/notebooks/notebooks_screen.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

class NotebooksSection extends StatelessWidget {
  const NotebooksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotebooksProvider>(
      builder: (context, provider, _) {
        final notebooks = provider.notebooks;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tappable header ──────────────────────────────
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotebooksScreen()),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 10),
                child: Row(
                  children: [
                    const Text('📚', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      'Defterlerim',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: FairyTheme.cream,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 12, color: FairyTheme.cream.withOpacity(0.7)),
                  ],
                ),
              ),
            ),

            // ── Horizontal list ──────────────────────────────
            SizedBox(
              height: 110,
              child: provider.isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: FairyTheme.cream,
                        strokeWidth: 2,
                      ),
                    )
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ...notebooks.map(
                          (nb) => Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: _NotebookMiniCard(
                              notebook: nb,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      NotebookDetailScreen(notebook: nb),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // "+" add card
                        _AddNotebookCard(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NotebooksScreen()),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _NotebookMiniCard extends StatelessWidget {
  final Notebook notebook;
  final VoidCallback onTap;

  const _NotebookMiniCard({required this.notebook, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        decoration: BoxDecoration(
          color: notebook.color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(10),
          ),
          border: Border.all(
            color: FairyTheme.inkBrown.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: notebook.color.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Spine
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: notebook.color.withOpacity(0.6),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                  border: Border(
                    right: BorderSide(
                        color: FairyTheme.inkBrown.withOpacity(0.15)),
                  ),
                ),
              ),
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(notebook.emoji,
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      notebook.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: FairyTheme.cream,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddNotebookCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddNotebookCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        decoration: BoxDecoration(
          color: FairyTheme.cardSurface.withOpacity(0.25),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(10),
          ),
          border: Border.all(
            color: FairyTheme.cream.withOpacity(0.5),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: FairyTheme.cream, size: 26),
            const SizedBox(height: 4),
            Text('Yeni',
                style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: FairyTheme.cream)),
          ],
        ),
      ),
    );
  }
}
