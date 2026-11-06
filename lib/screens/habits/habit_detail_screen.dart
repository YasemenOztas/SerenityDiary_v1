import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serenity_diary/models/habit.dart';
import 'package:serenity_diary/repository/habit_repository.dart';
import 'package:serenity_diary/screens/habits/add_edit_habit_screen.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;
  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late Habit _currentHabit;
  bool _loading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _currentHabit = widget.habit;
    _loadStats();
  }

  Future<void> _loadStats() async {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final stats = await HabitRepository.getDetailedStats(_currentHabit, todayStr);
    
    // We also need to refresh the habit itself in case it was edited
    final active = await HabitRepository.getActiveHabits();
    final archived = await HabitRepository.getArchivedHabits();
    final allHabits = [...active, ...archived];
    
    Habit updatedHabit = _currentHabit;
    try {
      updatedHabit = allHabits.firstWhere((h) => h.id == _currentHabit.id);
    } catch (e) {
      // Habit was permanently deleted
      if (mounted) Navigator.pop(context);
      return;
    }

    if (mounted) {
      setState(() {
        _stats = stats;
        _currentHabit = updatedHabit;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Column(
            children: [
              // ── AppBar ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: FairyTheme.cardSurface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: FairyTheme.gold.withOpacity(0.4)),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16, color: FairyTheme.inkBrown),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'İstatistikler',
                      style: GoogleFonts.dancingScript(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: FairyTheme.cream,
                      ),
                    ),
                    const Spacer(),
                    // Edit Button
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditHabitScreen(habit: _currentHabit),
                          ),
                        );
                        _loadStats();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: FairyTheme.gold,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: FairyTheme.goldDark.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.edit_rounded,
                            size: 18, color: FairyTheme.cream),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Title ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _currentHabit.title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: FairyTheme.cream,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // ── Stats Grid ──────────────────────────────────────
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _StatCard(
                                  emoji: '🔥',
                                  title: 'Mevcut Seri',
                                  value: '${_stats['currentStreak'] ?? 0}',
                                  subtitle: 'Gün',
                                )),
                                const SizedBox(width: 16),
                                Expanded(child: _StatCard(
                                  emoji: '👑',
                                  title: 'En Uzun Seri',
                                  value: '${_stats['longestStreak'] ?? 0}',
                                  subtitle: 'Gün',
                                )),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _StatCard(
                                  emoji: '🌿',
                                  title: 'Uygulanan',
                                  value: '${_stats['totalCompleted'] ?? 0}',
                                  subtitle: 'Gün',
                                )),
                                const SizedBox(width: 16),
                                Expanded(child: _StatCard(
                                  emoji: '🍂',
                                  title: 'Atlanan',
                                  value: '${_stats['totalMissed'] ?? 0}',
                                  subtitle: 'Gün',
                                  isWarning: true,
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String value;
  final String subtitle;
  final bool isWarning;

  const _StatCard({
    required this.emoji,
    required this.title,
    required this.value,
    required this.subtitle,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FairyTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isWarning ? FairyTheme.dustyRose : FairyTheme.gold.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: FairyTheme.inkBrown.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isWarning ? FairyTheme.berryPink : FairyTheme.medBrown,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: FairyTheme.inkBrown,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: FairyTheme.lightBrown,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
