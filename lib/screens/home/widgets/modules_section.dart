import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serenity_diary/screens/diary/diary_screen.dart';
import 'module_card.dart';

class ModulesSection extends StatelessWidget {
  const ModulesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Erişim',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3142),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            ModuleCard(
              title: 'Günlük',
              icon: Icons.book_rounded,
              color: const Color(0xFFE2D1F9), // Pastel Mor
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DiaryScreen()),
                );
              },
            ),
            ModuleCard(
              title: 'Su Takibi',
              icon: Icons.water_drop_rounded,
              color: const Color(0xFFBCE6EB), // Pastel Mavi
              onTap: () {
                // Su takibi sayfasına yönlendirme eklenecek
              },
            ),
            ModuleCard(
              title: 'Alışkanlık',
              icon: Icons.star_rounded,
              color: const Color(0xFFFDF0CC), // Pastel Sarı
              onTap: () {
                // Alışkanlık sayfasına yönlendirme eklenecek
              },
            ),
          ],
        ),
      ],
    );
  }
}
