import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serenity_diary/models/habit.dart';
import 'package:serenity_diary/repository/habit_repository.dart';
import 'package:serenity_diary/screens/habits/add_edit_habit_screen.dart';
import 'package:serenity_diary/screens/habits/archived_habits_screen.dart';
import 'package:serenity_diary/screens/habits/habit_detail_screen.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  List<Habit> _habits = [];
  bool _loading = true;
  int _highestStreak = 0;
  String _highestStreakName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final habits = await HabitRepository.getActiveHabits();
    
    // Calculate stats
    int bestStreak = 0;
    String bestName = '';
    String today = DateTime.now().toIso8601String().substring(0, 10);
    
    for (var h in habits) {
      final streak = await HabitRepository.getHabitStreak(h.id!, today);
      if (streak > bestStreak) {
        bestStreak = streak;
        bestName = h.title;
      }
    }

    if (mounted) {
      setState(() {
        _habits = habits;
        _highestStreak = bestStreak;
        _highestStreakName = bestName;
        _loading = false;
      });
    }
  }

  void _showArchiveDialog(Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FairyTheme.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: FairyTheme.gold.withOpacity(0.4)),
        ),
        title: Text('📦 Arşive Kaldır',
            style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: FairyTheme.inkBrown)),
        content: Text(
            'Bu alışkanlığı arşivlediğinde istatistiklerin korunur ama ana sayfada bir daha görünmez. Onaylıyor musun?',
            style: GoogleFonts.nunito(color: FairyTheme.medBrown)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('İptal',
                style: GoogleFonts.nunito(color: FairyTheme.lightBrown)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await HabitRepository.archiveHabit(habit.id!);
              _loadData();
            },
            child: Text('Arşivle',
                style: GoogleFonts.nunito(
                    color: FairyTheme.berryPink,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
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
                          border: Border.all(
                              color: FairyTheme.gold.withOpacity(0.4)),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16, color: FairyTheme.inkBrown),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Text('🌱', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text(
                          'Alışkanlıklarım',
                          style: GoogleFonts.dancingScript(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: FairyTheme.cream,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ArchivedHabitsScreen(),
                          ),
                        );
                        _loadData();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: FairyTheme.parchment.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: FairyTheme.gold.withOpacity(0.4)),
                        ),
                        child: Icon(Icons.archive_rounded,
                            size: 18, color: FairyTheme.medBrown),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Stats Card ──────────────────────────────────────
              if (!_loading && _habits.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: FairyTheme.parchment,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: FairyTheme.gold.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: FairyTheme.inkBrown.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: FairyTheme.leafGreen.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Text('🔥', style: TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'En İyi Seri',
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: FairyTheme.lightBrown,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _highestStreak > 0
                                    ? '$_highestStreakName ($_highestStreak gün)'
                                    : 'Henüz seri yok, bugün başla!',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: FairyTheme.inkBrown,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Habits List ─────────────────────────────────────
              Expanded(
                child: _loading
                    ? Center(child: CircularProgressIndicator())
                    : _habits.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('✨', style: TextStyle(fontSize: 48)),
                                const SizedBox(height: 12),
                                Text(
                                  'Henüz bir alışkanlık eklemedin...',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 16,
                                    color: FairyTheme.cream,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Aşağıdaki + butonundan hemen başla!',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    color: FairyTheme.cream.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _habits.length,
                            itemBuilder: (context, i) {
                              final h = _habits[i];
                              return _HabitItem(
                                habit: h,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HabitDetailScreen(habit: h),
                                    ),
                                  );
                                  _loadData();
                                },
                                onArchive: () => _showArchiveDialog(h),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditHabitScreen()),
          );
          _loadData();
        },
        backgroundColor: FairyTheme.gold,
        foregroundColor: FairyTheme.cream,
        elevation: 6,
        shape: const CircleBorder(),
        child: Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}

class _HabitItem extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onArchive;

  const _HabitItem({
    required this.habit,
    required this.onTap,
    required this.onArchive,
  });

  static const _days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FairyTheme.cream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FairyTheme.gold.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: FairyTheme.inkBrown.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: FairyTheme.inkBrown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: List.generate(7, (i) {
                      final dayNum = i + 1;
                      final isSelected = habit.selectedDays.contains(dayNum);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? FairyTheme.lavender : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? FairyTheme.lavenderDark : FairyTheme.parchmentDark,
                          ),
                        ),
                        child: Text(
                          _days[i],
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? FairyTheme.inkBrown : FairyTheme.lightBrown,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.archive_outlined, color: FairyTheme.dustyRose),
              onPressed: onArchive,
            ),
          ],
        ),
      ),
    );
  }
}
