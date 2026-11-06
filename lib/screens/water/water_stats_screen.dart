import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:serenity_diary/models/water_entry.dart';
import 'package:serenity_diary/repository/water_repository.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

class WaterStatsScreen extends StatefulWidget {
  final int adjustedGoalMl;
  const WaterStatsScreen({super.key, required this.adjustedGoalMl});

  @override
  State<WaterStatsScreen> createState() => _WaterStatsScreenState();
}

class _WaterStatsScreenState extends State<WaterStatsScreen> {
  List<WaterEntry> _all = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await WaterRepository.getAllEntries();
    if (mounted) setState(() { _all = entries; _loading = false; });
  }

  Future<void> _delete(int id) async {
    await WaterRepository.delete(id);
    _load();
  }

  /// Group entries by date string 'dd MMM yyyy'
  Map<String, List<WaterEntry>> get _grouped {
    final map = <String, List<WaterEntry>>{};
    for (final e in _all) {
      final key = DateFormat('dd MMMM yyyy', 'tr').format(e.createdAt);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  Color _dayColor(int totalMl) {
    final ratio = totalMl / widget.adjustedGoalMl;
    if (ratio >= 2.0) return FairyTheme.berryPink;
    if (ratio >= 1.0) return FairyTheme.leafGreen;
    if (ratio >= 0.5) return FairyTheme.mint;
    return FairyTheme.parchmentDark;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final dateKeys = grouped.keys.toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6B7D58), FairyTheme.bgSage, Color(0xFF8A9B76)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
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
                        const Text('📊', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text('Tüm Kayıtlar',
                            style: GoogleFonts.dancingScript(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: FairyTheme.cream)),
                      ],
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _loading
                    ? Center(child: CircularProgressIndicator(color: FairyTheme.cream))
                    : _all.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('💧', style: TextStyle(fontSize: 48)),
                                const SizedBox(height: 12),
                                Text('Henüz hiç kayıt yok',
                                    style: GoogleFonts.playfairDisplay(
                                        fontSize: 16,
                                        color: FairyTheme.cream,
                                        fontStyle: FontStyle.italic)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: dateKeys.length,
                            itemBuilder: (context, i) {
                              final key = dateKeys[i];
                              final entries = grouped[key]!;
                              final dayTotal = entries.fold<int>(0, (s, e) => s + e.amountMl);
                              final color = _dayColor(dayTotal);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  // Day header
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: color.withOpacity(0.5)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          dayTotal >= widget.adjustedGoalMl * 2
                                              ? Icons.water_drop
                                              : dayTotal >= widget.adjustedGoalMl
                                                  ? Icons.check_circle_outline_rounded
                                                  : Icons.radio_button_unchecked_rounded,
                                          color: color,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(key,
                                            style: GoogleFonts.nunito(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: FairyTheme.cream)),
                                        const Spacer(),
                                        Text('$dayTotal ml',
                                            style: GoogleFonts.nunito(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                                color: color)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Entries for that day
                                  Container(
                                    decoration: FairyTheme.parchmentCard(),
                                    child: Column(
                                      children: entries.map((entry) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: FairyTheme.mintLight.withOpacity(0.6),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text('💧', style: TextStyle(fontSize: 16)),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text('${entry.amountMl} ml',
                                                  style: GoogleFonts.nunito(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w700,
                                                      color: FairyTheme.inkBrown)),
                                              const Spacer(),
                                              Text(
                                                DateFormat('HH:mm').format(entry.createdAt),
                                                style: GoogleFonts.nunito(
                                                    fontSize: 12,
                                                    color: FairyTheme.lightBrown),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
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
