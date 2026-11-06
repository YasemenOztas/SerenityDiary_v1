import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:serenity_diary/providers/preferences_provider.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

class MyGardenScreen extends StatelessWidget {
  const MyGardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FairyTheme.bgSage,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2E3B32), // Dark mystical forest green
                  Color(0xFF4A5D4E),
                  FairyTheme.bgSage,
                ],
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: FairyTheme.cream.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: FairyTheme.cream.withOpacity(0.3)),
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: FairyTheme.cream),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Sanal Bahçem',
                        style: GoogleFonts.dancingScript(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: FairyTheme.cream,
                        ),
                      ),
                      const Spacer(),
                      // Pixie dust indicator
                      Consumer<PreferencesProvider>(
                        builder: (context, prefs, _) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: FairyTheme.goldDark.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: FairyTheme.gold),
                            boxShadow: [
                              BoxShadow(
                                color: FairyTheme.gold.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              const Text('✨', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(
                                '${prefs.pixieDust}',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: FairyTheme.cream,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Garden Image
                Expanded(
                  child: Consumer<PreferencesProvider>(
                    builder: (context, prefs, _) {
                      final level = prefs.gardenLevel.clamp(1, 3);
                      return Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(seconds: 1),
                          child: Container(
                            key: ValueKey<int>(level),
                            margin: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: FairyTheme.gold.withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                'assets/garden_$level.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Info & Upgrade
                Consumer<PreferencesProvider>(
                  builder: (context, prefs, _) {
                    final isMaxLevel = prefs.gardenLevel >= 3;
                    final cost = prefs.gardenLevel * 50;
                    final canAfford = prefs.pixieDust >= cost;

                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: FairyTheme.cardSurface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isMaxLevel ? 'Görkemli Sihirli Ağaç' : 'Seviye ${prefs.gardenLevel} Sihirli Bitki',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: FairyTheme.inkBrown,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isMaxLevel
                                ? 'Bahçen olabilecek en büyüleyici seviyeye ulaştı! Sihir tozlarını biriktirmeye devam et.'
                                : 'Görevlerini tamamlayıp sihir tozu toplayarak bahçeni büyüt!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              color: FairyTheme.medBrown,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (!isMaxLevel)
                            ElevatedButton(
                              onPressed: canAfford
                                  ? () async {
                                      final success = await prefs.spendPixieDust(cost);
                                      if (success) {
                                        await prefs.levelUpGarden();
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FairyTheme.leafGreen,
                                disabledBackgroundColor: FairyTheme.lightBrown.withOpacity(0.3),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: canAfford ? 4 : 0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.water_drop_rounded, color: FairyTheme.cream),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Sula ve Büyüt ($cost ✨)',
                                    style: GoogleFonts.nunito(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: FairyTheme.cream,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
