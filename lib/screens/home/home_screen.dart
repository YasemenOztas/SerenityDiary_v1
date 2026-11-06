import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serenity_diary/screens/garden/my_garden_screen.dart';
import 'package:serenity_diary/screens/settings/settings_screen.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';
import 'widgets/home_header.dart';
import 'widgets/motivation_card.dart';
import 'widgets/fairy_diary_card.dart';
import 'widgets/water_tracker_card.dart';
import 'widgets/notebooks_section.dart';
import 'widgets/habits_frame.dart';
import 'widgets/home_calendar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // ── Decorative top corners ─────────────────────────
                Stack(
                  children: [
                    Positioned(
                      left: -8,
                      top: -4,
                      child: Text('🌿',
                          style: TextStyle(
                              fontSize: 40,
                              color: Colors.white.withOpacity(0.15))),
                    ),
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Text('🌿',
                          style: TextStyle(
                              fontSize: 40,
                              color: Colors.white.withOpacity(0.15))),
                    ),
                    Center(child: HomeHeader()),
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Builder(
                        builder: (ctx) => IconButton(
                          icon: Icon(Icons.menu_rounded, color: FairyTheme.cream, size: 28),
                          onPressed: () => Scaffold.of(ctx).openDrawer(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Motivation card ────────────────────────────────
                const MotivationCard(),

                const SizedBox(height: 16),

                // ── Main row: Diary + Water ────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Expanded(flex: 3, child: FairyDiaryCard()),
                    SizedBox(width: 12),
                    Expanded(flex: 2, child: WaterTrackerCard()),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Notebooks horizontal ───────────────────────────
                const NotebooksSection(),

                const SizedBox(height: 16),

                // ── Habits frame ───────────────────────────────────
                const HabitsFrame(),

                const SizedBox(height: 16),

                // ── Calendar ──────────────────────────────────────
                const HomeCalendar(),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: FairyTheme.bgSage,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: FairyTheme.cardSurface,
            ),
            child: Center(
              child: Text(
                'Sihirli Günlüğüm',
                style: GoogleFonts.dancingScript(
                  fontSize: 32,
                  color: FairyTheme.inkBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Text('🍄', style: TextStyle(fontSize: 24)),
            title: Text('Sanal Bahçem', style: GoogleFonts.nunito(fontSize: 18, color: FairyTheme.cream, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context); // close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyGardenScreen()),
              );
            },
          ),
          ListTile(
            leading: const Text('⚙️', style: TextStyle(fontSize: 24)),
            title: Text('Ayarlar', style: GoogleFonts.nunito(fontSize: 18, color: FairyTheme.cream, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
