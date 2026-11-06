import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serenity_diary/models/habit.dart';
import 'package:serenity_diary/repository/habit_repository.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

class AddEditHabitScreen extends StatefulWidget {
  final Habit? habit;
  const AddEditHabitScreen({super.key, this.habit});

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  late final TextEditingController _titleController;
  final List<int> _selectedDays = [];

  static const _dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit?.title ?? '');
    if (widget.habit != null) {
      _selectedDays.addAll(widget.habit!.selectedDays);
    } else {
      // Default to everyday
      _selectedDays.addAll([1, 2, 3, 4, 5, 6, 7]);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _toggleDay(int dayNum) {
    setState(() {
      if (_selectedDays.contains(dayNum)) {
        if (_selectedDays.length > 1) { // Prevent unselecting all
          _selectedDays.remove(dayNum);
        }
      } else {
        _selectedDays.add(dayNum);
        _selectedDays.sort();
      }
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    if (widget.habit == null) {
      await HabitRepository.insertHabit(Habit(
        title: title,
        selectedDays: _selectedDays,
        createdAt: DateTime.now(),
      ));
    } else {
      await HabitRepository.updateHabit(Habit(
        id: widget.habit!.id,
        title: title,
        selectedDays: _selectedDays,
        createdAt: widget.habit!.createdAt,
        isArchived: widget.habit!.isArchived,
      ));
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    await HabitRepository.deleteHabit(widget.habit!.id!);
    if (mounted) Navigator.pop(context);
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FairyTheme.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: FairyTheme.gold.withOpacity(0.4)),
        ),
        title: Text('🗑️ Sil',
            style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: FairyTheme.inkBrown)),
        content: Text('Bu alışkanlığı ve tüm istatistiklerini kalıcı olarak silmek istediğine emin misin?',
            style: GoogleFonts.nunito(color: FairyTheme.medBrown)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('İptal',
                style: GoogleFonts.nunito(color: FairyTheme.lightBrown)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _delete();
            },
            child: Text('Evet, Sil',
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
                    Text(
                      widget.habit == null ? '✨ Yeni Alışkanlık' : '🖊️ Düzenle',
                      style: GoogleFonts.dancingScript(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: FairyTheme.cream,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (widget.habit != null) ...[
                          GestureDetector(
                            onTap: _showDeleteDialog,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: FairyTheme.dustyRose.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: FairyTheme.berryPink.withOpacity(0.4)),
                              ),
                              child: Icon(Icons.delete_outline_rounded,
                                  size: 18, color: FairyTheme.berryPink),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        GestureDetector(
                          onTap: _save,
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
                            child: Icon(Icons.check_rounded,
                                size: 18, color: FairyTheme.cream),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Form Area ─────────────────────────────────────
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: FairyTheme.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: FairyTheme.gold.withOpacity(0.4), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: FairyTheme.inkBrown.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alışkanlık Adı',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: FairyTheme.inkBrown,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _titleController,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: FairyTheme.medBrown,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Örn: Kitap Oku, Su İç, Gitar Çal...',
                          hintStyle: GoogleFonts.nunito(
                            fontSize: 15,
                            color: FairyTheme.lightBrown.withOpacity(0.5),
                            fontStyle: FontStyle.italic,
                          ),
                          filled: true,
                          fillColor: FairyTheme.parchment.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: FairyTheme.parchmentDark.withOpacity(0.5)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: FairyTheme.parchmentDark.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: FairyTheme.gold.withOpacity(0.8), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      Text(
                        'Hangi Günler?',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: FairyTheme.inkBrown,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(7, (index) {
                          final dayNum = index + 1;
                          final isSelected = _selectedDays.contains(dayNum);
                          return GestureDetector(
                            onTap: () => _toggleDay(dayNum),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isSelected ? FairyTheme.lavender : FairyTheme.parchment,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? FairyTheme.lavenderDark : FairyTheme.parchmentDark,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: FairyTheme.lavenderDark.withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  _dayNames[index],
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? FairyTheme.inkBrown : FairyTheme.lightBrown,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      
                      const Spacer(),
                      // Decorative element
                      Center(
                        child: Text('🌸', style: TextStyle(fontSize: 32, color: FairyTheme.lightBrown.withOpacity(0.5))),
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
