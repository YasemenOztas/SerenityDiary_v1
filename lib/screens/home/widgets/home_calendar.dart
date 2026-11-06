import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:serenity_diary/providers/water/water_provider.dart';
import 'package:serenity_diary/repository/habit_repository.dart';
import 'package:serenity_diary/repository/note_repository.dart';
import 'package:serenity_diary/repository/water_repository.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

class HomeCalendar extends StatefulWidget {
  const HomeCalendar({super.key});

  @override
  State<HomeCalendar> createState() => _HomeCalendarState();
}

class _HomeCalendarState extends State<HomeCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Data maps
  Set<String> _monthNotes = {};
  Map<String, int> _monthWater = {};
  Map<String, bool> _monthHabits = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadMonthData(_focusedDay);
  }

  Future<void> _loadMonthData(DateTime month) async {
    final year = month.year;
    final m = month.month;

    final notes = await NoteRepository.getNoteDatesForMonth(year, m);
    final water = await WaterRepository.getDailyTotalsForMonth(year, m);
    final habits = await HabitRepository.getHabitStatusForMonth(year, m);

    if (mounted) {
      setState(() {
        _monthNotes = notes;
        _monthWater = water;
        _monthHabits = habits;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // We get the current water goal to use as threshold for all days.
    // This allows the user's current settings (weather, activity) to define what a "successful" day looks like.
    final waterProvider = context.watch<WaterProvider>();
    final currentWaterGoal = waterProvider.adjustedGoalMl;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FairyTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FairyTheme.gold.withOpacity(0.45), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: FairyTheme.inkBrown.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
          _loadMonthData(focusedDay);
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: FairyTheme.inkBrown,
            fontStyle: FontStyle.italic,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: FairyTheme.medBrown,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: FairyTheme.medBrown,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: FairyTheme.medBrown,
          ),
          weekendStyle: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: FairyTheme.berryPink,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final dateStr = day.toIso8601String().substring(0, 10);
            return _buildCellContent(day, _isPerfectDay(dateStr, currentWaterGoal), false, false);
          },
          todayBuilder: (context, day, focusedDay) {
            final dateStr = day.toIso8601String().substring(0, 10);
            return _buildCellContent(day, _isPerfectDay(dateStr, currentWaterGoal), true, false);
          },
          selectedBuilder: (context, day, focusedDay) {
            final dateStr = day.toIso8601String().substring(0, 10);
            return _buildCellContent(day, _isPerfectDay(dateStr, currentWaterGoal), false, true);
          },
          markerBuilder: (context, day, events) {
            final dateStr = day.toIso8601String().substring(0, 10);
            final hasNote = _monthNotes.contains(dateStr);
            final totalWater = _monthWater[dateStr] ?? 0;
            final hasWater = totalWater >= currentWaterGoal;
            final allHabits = _monthHabits[dateStr] ?? false;

            if (!hasNote && !hasWater && !allHabits) return null;

            final isPerfect = hasNote && hasWater && allHabits;

            return Positioned(
              bottom: 6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPerfect)
                    const Text('✨', style: TextStyle(fontSize: 14))
                  else ...[
                    if (hasNote) const Text('🪶', style: TextStyle(fontSize: 10)),
                    if (hasWater) const Text('💧', style: TextStyle(fontSize: 10)),
                    if (allHabits) const Text('🌿', style: TextStyle(fontSize: 10)),
                  ]
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCellContent(DateTime day, bool isPerfect, bool isToday, bool isSelected) {
    Color bgColor = Colors.transparent;
    Color? borderColor;

    if (isSelected) {
      bgColor = FairyTheme.lavender.withOpacity(0.7);
    } else if (isToday) {
      bgColor = FairyTheme.lavender.withOpacity(0.3);
      borderColor = FairyTheme.lavenderDark;
    } else if (isPerfect) {
      bgColor = FairyTheme.gold.withOpacity(0.35);
      borderColor = FairyTheme.gold.withOpacity(0.6);
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null ? Border.all(color: borderColor, width: isToday ? 1.5 : 1) : null,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '${day.day}',
            style: GoogleFonts.nunito(
              color: day.weekday == DateTime.saturday || day.weekday == DateTime.sunday
                  ? FairyTheme.berryPink
                  : FairyTheme.inkBrown,
              fontWeight: (isPerfect || isToday || isSelected) ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  bool _isPerfectDay(String dateStr, int waterGoal) {
    final hasNote = _monthNotes.contains(dateStr);
    final totalWater = _monthWater[dateStr] ?? 0;
    final hasWater = totalWater >= waterGoal;
    final allHabits = _monthHabits[dateStr] ?? false;

    return hasNote && hasWater && allHabits;
  }
}
