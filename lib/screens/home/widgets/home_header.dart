import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left decorative
        Text('🌿', style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 8),
        // Title
        Text(
          'Serenity',
          style: GoogleFonts.dancingScript(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            color: FairyTheme.cream,
            shadows: [
              Shadow(
                color: FairyTheme.inkBrown.withOpacity(0.3),
                offset: const Offset(1, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Heart icon
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: FairyTheme.dustyRose.withOpacity(0.8),
            shape: BoxShape.circle,
            border: Border.all(color: FairyTheme.gold.withOpacity(0.5)),
          ),
          child: Icon(
            Icons.favorite,
            color: FairyTheme.berryPink,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        // Right decorative
        Text('🦋', style: const TextStyle(fontSize: 20)),
      ],
    );
  }
}
