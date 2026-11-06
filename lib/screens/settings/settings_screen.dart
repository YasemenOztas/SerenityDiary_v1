import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:serenity_diary/providers/preferences_provider.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FairyTheme.bgSage,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: FairyTheme.cream),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ayarlar',
          style: GoogleFonts.dancingScript(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: FairyTheme.cream,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<PreferencesProvider>(
        builder: (context, prefs, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Theme settings
              Container(
                padding: const EdgeInsets.all(20),
                decoration: FairyTheme.parchmentCard(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('✨', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          'Uygulama Teması',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: FairyTheme.inkBrown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildThemeOption(
                      context: context,
                      theme: ThemeType.fairyDay,
                      currentTheme: prefs.appTheme,
                      title: '🌿 Gündüz Perisi',
                      subtitle: 'Ferah ve aydınlık bahar sabahı.',
                      onTap: () => prefs.setAppTheme(ThemeType.fairyDay),
                    ),
                    const SizedBox(height: 12),
                    _buildThemeOption(
                      context: context,
                      theme: ThemeType.nightForest,
                      currentTheme: prefs.appTheme,
                      title: '🌙 Gece Ormanı',
                      subtitle: 'Karanlıkta parlayan ateşböcekleri.',
                      onTap: () => prefs.setAppTheme(ThemeType.nightForest),
                    ),
                    const SizedBox(height: 12),
                    _buildThemeOption(
                      context: context,
                      theme: ThemeType.autumnMagic,
                      currentTheme: prefs.appTheme,
                      title: '🍂 Güz Büyüsü',
                      subtitle: 'Sıcak ve nostaljik sonbahar tonları.',
                      onTap: () => prefs.setAppTheme(ThemeType.autumnMagic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Motivation text
              Container(
                padding: const EdgeInsets.all(20),
                decoration: FairyTheme.parchmentCard(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('📜', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          'Motivasyon Sözü',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: FairyTheme.inkBrown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: TextEditingController(text: prefs.motivationText),
                      onSubmitted: (value) => prefs.setMotivationText(value),
                      style: GoogleFonts.nunito(color: FairyTheme.inkBrown, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Kendine zaman ayır! ✨',
                        filled: true,
                        fillColor: FairyTheme.parchment,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: FairyTheme.goldDark.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: FairyTheme.leafGreen, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Klavyeden onaylayarak (Enter) kaydedebilirsin.',
                      style: GoogleFonts.nunito(fontSize: 12, color: FairyTheme.medBrown),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeType theme,
    required ThemeType currentTheme,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isSelected = theme == currentTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? FairyTheme.lavender.withOpacity(0.4) : FairyTheme.parchment,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? FairyTheme.lavenderDark : FairyTheme.gold.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: FairyTheme.inkBrown,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: FairyTheme.medBrown,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: FairyTheme.leafGreen),
          ],
        ),
      ),
    );
  }
}
