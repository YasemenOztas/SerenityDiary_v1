import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serenity_diary/models/habit.dart';
import 'package:serenity_diary/repository/habit_repository.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

class ArchivedHabitsScreen extends StatefulWidget {
  const ArchivedHabitsScreen({super.key});

  @override
  State<ArchivedHabitsScreen> createState() => _ArchivedHabitsScreenState();
}

class _ArchivedHabitsScreenState extends State<ArchivedHabitsScreen> {
  List<Habit> _archivedHabits = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final habits = await HabitRepository.getArchivedHabits();
    if (mounted) {
      setState(() {
        _archivedHabits = habits;
        _loading = false;
      });
    }
  }

  Future<void> _unarchive(Habit habit) async {
    await HabitRepository.unarchiveHabit(habit.id!);
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${habit.title} geri getirildi! 🌱'),
          backgroundColor: FairyTheme.leafGreen,
        ),
      );
    }
  }

  void _showDeleteDialog(Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FairyTheme.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: FairyTheme.gold.withOpacity(0.4)),
        ),
        title: Text('Kalıcı Sil',
            style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: FairyTheme.inkBrown)),
        content: Text(
            '${habit.title} tamamen silinecek. Tüm istatistikler ve geçmiş yok olacak. Onaylıyor musun?',
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
              await HabitRepository.deleteHabit(habit.id!);
              _loadData();
            },
            child: Text('Kalıcı Olarak Sil',
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
                          border: Border.all(color: FairyTheme.gold.withOpacity(0.4)),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16, color: FairyTheme.inkBrown),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Text('📦', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text(
                          'Arşiv',
                          style: GoogleFonts.dancingScript(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: FairyTheme.cream,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // ── List ──────────────────────────────────────────
              Expanded(
                child: _loading
                    ? Center(child: CircularProgressIndicator())
                    : _archivedHabits.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🌬️', style: TextStyle(fontSize: 48)),
                                const SizedBox(height: 12),
                                Text(
                                  'Arşiv boş...',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 16,
                                    color: FairyTheme.cream,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _archivedHabits.length,
                            itemBuilder: (context, i) {
                              final h = _archivedHabits[i];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: FairyTheme.parchment.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: FairyTheme.parchmentDark),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        h.title,
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: FairyTheme.inkBrown,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.restore_rounded),
                                      color: FairyTheme.leafGreen,
                                      tooltip: 'Geri Getir',
                                      onPressed: () => _unarchive(h),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_forever_rounded),
                                      color: FairyTheme.berryPink,
                                      tooltip: 'Kalıcı Sil',
                                      onPressed: () => _showDeleteDialog(h),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
