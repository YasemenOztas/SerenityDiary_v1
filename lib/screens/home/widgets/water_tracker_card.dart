import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:serenity_diary/providers/water/water_provider.dart';
import 'package:serenity_diary/providers/preferences_provider.dart';
import 'package:serenity_diary/screens/water/water_screen.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

class WaterTrackerCard extends StatelessWidget {
  const WaterTrackerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, water, _) {
        final progress = water.progress.clamp(0.0, 1.0);
        final isDoubleOver = water.progress >= 2.0;
        final isGoalMet = water.progress >= 1.0;

        return Column(
          children: [
            // ── Jar card ─────────────────────────────────────
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WaterScreen()),
              ),
              child: Container(
                height: 162,
                decoration: BoxDecoration(
                  color: FairyTheme.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: FairyTheme.gold.withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: FairyTheme.inkBrown.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.5),
                  child: Stack(
                    children: [
                      // Water fill
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                          height: 162 * progress,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isDoubleOver
                                  ? [
                                      const Color(0xFFE8A0B0),
                                      FairyTheme.berryPink,
                                    ]
                                  : [
                                      FairyTheme.mintLight,
                                      FairyTheme.mint,
                                    ],
                            ),
                          ),
                        ),
                      ),
                      // Over-goal overlay
                      if (isDoubleOver)
                        Positioned.fill(
                          child: Container(
                            color: FairyTheme.berryPink.withOpacity(0.2),
                          ),
                        )
                      else if (isGoalMet)
                        Positioned.fill(
                          child: Container(
                            color: FairyTheme.gold.withOpacity(0.15),
                          ),
                        ),
                      // Content
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Text(isDoubleOver ? '🌊' : isGoalMet ? '🌟' : '🧚',
                                 style: const TextStyle(fontSize: 24)),
                            const SizedBox(height: 4),
                            Text(
                              'Su Takibi',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: FairyTheme.inkBrown,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: FairyTheme.cardSurface.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${water.todayTotalMl} ml',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: isDoubleOver
                                      ? FairyTheme.berryPink
                                      : isGoalMet
                                          ? FairyTheme.leafGreen
                                          : FairyTheme.medBrown,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '/ ${water.adjustedGoalMl} ml',
                              style: GoogleFonts.nunito(
                                fontSize: 10,
                                color: FairyTheme.medBrown,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ── + button (200 ml) ──────────────────────────
            GestureDetector(
              onTap: () async {
                await water.addMl(200);
                if (water.progress >= 1.0) {
                  final prefs = context.read<PreferencesProvider>();
                  final todayStr = DateTime.now().toIso8601String().substring(0, 10);
                  final granted = await prefs.claimWaterReward(todayStr);
                  if (granted && context.mounted) {
                    await prefs.addPixieDust(5);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('✨ Su hedefine ulaştın! +5 Sihir Tozu!'),
                        backgroundColor: FairyTheme.leafGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                }
              },
              child: Container(
                width: double.infinity,
                height: 30,
                decoration: BoxDecoration(
                  color: FairyTheme.gold,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: FairyTheme.goldDark.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded,
                          color: FairyTheme.cream, size: 18),
                      const SizedBox(width: 2),
                      Text(
                        '200 ml',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: FairyTheme.cream,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
