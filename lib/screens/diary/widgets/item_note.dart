import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:serenity_diary/models/note.dart' show Note;
import 'package:serenity_diary/screens/diary/add-note/add_note_screen.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

class ItemNote extends StatelessWidget {
  final Note note;
  const ItemNote({super.key, required this.note});

  // Rotate cards slightly for scrapbook feel
  static final List<double> _rotations = [
    -0.01, 0.008, -0.005, 0.012, -0.007
  ];

  @override
  Widget build(BuildContext context) {
    final rotAngle =
        _rotations[note.id != null ? note.id! % _rotations.length : 0];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddNoteScreen(note: note)),
      ),
      child: Transform.rotate(
        angle: rotAngle,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FairyTheme.cream,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: FairyTheme.gold.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: FairyTheme.inkBrown.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: FairyTheme.lavender.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: FairyTheme.lavenderDark.withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('MMM').format(note.createdAt).toUpperCase(),
                      style: GoogleFonts.nunito(
                        color: FairyTheme.medBrown,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('d').format(note.createdAt),
                      style: GoogleFonts.playfairDisplay(
                        color: FairyTheme.inkBrown,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('yyyy').format(note.createdAt),
                      style: GoogleFonts.nunito(
                        color: FairyTheme.lightBrown,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            note.title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: FairyTheme.inkBrown,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          DateFormat('HH:mm').format(note.createdAt),
                          style: GoogleFonts.nunito(
                            color: FairyTheme.lightBrown,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Faint divider line
                    Container(
                      height: 1,
                      color: FairyTheme.parchmentDark.withOpacity(0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      note.description,
                      style: GoogleFonts.nunito(
                        color: FairyTheme.medBrown,
                        fontSize: 13,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Decorative flower
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        '🌼',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.amber.withOpacity(0.8)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
