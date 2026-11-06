import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serenity_diary/screens/diary/diary_screen.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

class FairyDiaryCard extends StatelessWidget {
  const FairyDiaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DiaryScreen()),
      ),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: FairyTheme.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FairyTheme.gold.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: FairyTheme.inkBrown.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Book spine simulation on left
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 18,
              child: Container(
                decoration: BoxDecoration(
                  color: FairyTheme.parchmentDark,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  border: Border(
                    right: BorderSide(
                      color: FairyTheme.goldDark.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ),
            // Faint ruled lines (decorative)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(left: 30, top: 12, right: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quill icon
                    Row(
                      children: [
                        Text('🪶', style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 6),
                        Text(
                          'Günlük',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 13,
                            color: FairyTheme.lightBrown,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bugün ne\nhissettin?',
                      style: GoogleFonts.dancingScript(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: FairyTheme.inkBrown,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'What did you feel today?',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 11,
                        color: FairyTheme.lightBrown,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Tap hint
                    Row(
                      children: [
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 10, color: FairyTheme.medBrown),
                        const SizedBox(width: 4),
                        Text(
                          'Yazmaya başla',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: FairyTheme.medBrown,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Decorative flower corner
            Positioned(
              bottom: 10,
              right: 10,
              child: Text('🌸', style: const TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }
}
