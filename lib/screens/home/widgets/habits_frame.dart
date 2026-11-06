import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:serenity_diary/models/habit.dart';
import 'package:serenity_diary/models/habit_log.dart';
import 'package:serenity_diary/providers/preferences_provider.dart';
import 'package:serenity_diary/repository/habit_repository.dart';
import 'package:serenity_diary/screens/habits/habits_screen.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

class HabitsFrame extends StatefulWidget {
  const HabitsFrame({super.key});

  @override
  State<HabitsFrame> createState() => _HabitsFrameState();
}

class _HabitsFrameState extends State<HabitsFrame> {
  List<Habit> _todaysHabits = [];
  Map<int, bool> _completionStatus = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final now = DateTime.now();
    final todayWeekday = now.weekday; // 1 = Mon, 7 = Sun
    final todayDateStr = now.toIso8601String().substring(0, 10);

    final allActive = await HabitRepository.getActiveHabits();
    
    // Filter to only those scheduled for today
    final todays = allActive.where((h) => h.selectedDays.contains(todayWeekday)).toList();
    
    // Fetch logs for today
    final logs = await HabitRepository.getLogsForDate(todayDateStr);
    
    final statusMap = <int, bool>{};
    for (var log in logs) {
      statusMap[log.habitId] = log.isCompleted;
    }

    if (mounted) {
      setState(() {
        _todaysHabits = todays;
        _completionStatus = statusMap;
        _loading = false;
      });
    }
  }

  Future<void> _toggleHabit(Habit habit, bool? value) async {
    final bool isCompleted = value ?? false;
    final todayDateStr = DateTime.now().toIso8601String().substring(0, 10);

    // Optimistic UI update
    setState(() {
      _completionStatus[habit.id!] = isCompleted;
    });

    await HabitRepository.toggleLog(habit.id!, todayDateStr, isCompleted);
    
    if (isCompleted && mounted) {
      final prefs = context.read<PreferencesProvider>();
      await prefs.addPixieDust(2);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✨ +2 Sihir Tozu!'),
          backgroundColor: FairyTheme.leafGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (!isCompleted && mounted) {
      final prefs = context.read<PreferencesProvider>();
      await prefs.removePixieDust(2);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🍂 Alışkanlık geri alındı. -2 Sihir Tozu.'),
          backgroundColor: FairyTheme.dustyRose,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Refresh to ensure we have the correct state
    _loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FairyTheme.parchment,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FairyTheme.goldDark.withOpacity(0.6), width: 2),
        boxShadow: [
          BoxShadow(
            color: FairyTheme.inkBrown.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - tappable
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HabitsScreen()),
              );
              _loadHabits(); // Refresh after coming back from management screen
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: FairyTheme.parchmentDark.withOpacity(0.6),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  const Text('🌟', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    'Bugünkü Alışkanlıklarım',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: FairyTheme.inkBrown,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: FairyTheme.medBrown,
                  ),
                ],
              ),
            ),
          ),
          // Body
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: _loading
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _todaysHabits.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🌿', style: TextStyle(fontSize: 24)),
                              const SizedBox(height: 6),
                              Text(
                                'Bugün için planlanan\nbir alışkanlık yok.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  color: FairyTheme.medBrown,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: _todaysHabits.map((habit) {
                          final isDone = _completionStatus[habit.id] ?? false;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isDone,
                                  onChanged: (val) => _toggleHabit(habit, val),
                                  activeColor: FairyTheme.leafGreen,
                                  checkColor: FairyTheme.cream,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  side: BorderSide(
                                    color: FairyTheme.medBrown.withOpacity(0.5),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    habit.title,
                                    style: GoogleFonts.dancingScript(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: isDone
                                          ? FairyTheme.lightBrown.withOpacity(0.6)
                                          : FairyTheme.inkBrown,
                                      decoration: isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                      decorationThickness: 2,
                                    ),
                                  ),
                                ),
                                if (isDone)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 12.0),
                                    child: Text('✨', style: TextStyle(fontSize: 14)),
                                  )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
          ),
        ],
      ),
    );
  }
}
