import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:serenity_diary/providers/preferences_provider.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

class MotivationCard extends StatelessWidget {
  const MotivationCard({super.key});

  void _showEditDialog(BuildContext context, String current) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FairyTheme.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: FairyTheme.gold.withOpacity(0.5)),
        ),
        title: Row(
          children: [
            const Text('📌 '),
            Text(
              'Motivasyon Cümlen',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: FairyTheme.inkBrown,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          maxLength: 80,
          style: GoogleFonts.dancingScript(
            fontSize: 18,
            color: FairyTheme.inkBrown,
          ),
          decoration: InputDecoration(
            hintText: 'Kendine zaman ayır! ✨',
            hintStyle: GoogleFonts.dancingScript(
              color: FairyTheme.lightBrown.withOpacity(0.5),
            ),
            filled: true,
            fillColor: FairyTheme.parchment,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: FairyTheme.gold.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: FairyTheme.goldDark, width: 1.5),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('İptal',
                style:
                    GoogleFonts.nunito(color: FairyTheme.lightBrown)),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<PreferencesProvider>()
                  .setMotivationText(controller.text);
              Navigator.pop(ctx);
            },
            child: Text(
              'Kaydet',
              style: GoogleFonts.nunito(
                color: FairyTheme.goldDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferencesProvider>(
      builder: (context, prefs, _) {
        return GestureDetector(
          onLongPress: () =>
              _showEditDialog(context, prefs.motivationText),
          child: Transform.rotate(
            angle: -0.008,
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: FairyTheme.parchment,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: FairyTheme.goldDark.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: FairyTheme.inkBrown.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Thumbtack
                  Positioned(
                    top: -22,
                    right: 12,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: FairyTheme.goldDark,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: FairyTheme.inkBrown.withOpacity(0.3),
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Edit hint icon
                  Positioned(
                    bottom: -6,
                    right: 0,
                    child: Icon(
                      Icons.edit_note_rounded,
                      size: 14,
                      color: FairyTheme.lightBrown.withOpacity(0.5),
                    ),
                  ),
                  // Quote text
                  Center(
                    child: Text(
                      prefs.motivationText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dancingScript(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: FairyTheme.medBrown,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
