import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:serenity_diary/models/water_entry.dart';
import 'package:serenity_diary/providers/preferences_provider.dart';
import 'package:serenity_diary/providers/water/water_provider.dart';
import 'package:serenity_diary/screens/water/water_stats_screen.dart';
import 'package:serenity_diary/theme/fairy_theme.dart';

class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});
  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  // Controller for the quick-add text field
  final _mlController = TextEditingController();

  @override
  void dispose() {
    _mlController.dispose();
    super.dispose();
  }

  // ── Dialogs ────────────────────────────────────────────────────

  void _showGoalDialog(BuildContext context, int current) {
    final ctrl = TextEditingController(text: current.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FairyTheme.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: FairyTheme.gold.withOpacity(0.4)),
        ),
        title: Text('🎯 Günlük Hedef',
            style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                color: FairyTheme.inkBrown,
                fontWeight: FontWeight.w600)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: GoogleFonts.nunito(color: FairyTheme.inkBrown, fontSize: 18),
          decoration: InputDecoration(
            suffixText: 'ml',
            suffixStyle: GoogleFonts.nunito(color: FairyTheme.medBrown),
            filled: true,
            fillColor: FairyTheme.parchment,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: FairyTheme.gold.withOpacity(0.3)),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('İptal',
                  style: GoogleFonts.nunito(color: FairyTheme.lightBrown))),
          TextButton(
            onPressed: () {
              final ml = int.tryParse(ctrl.text);
              if (ml != null && ml >= 500) {
                context.read<WaterProvider>().setGoal(ml);
              }
              Navigator.pop(ctx);
            },
            child: Text('Kaydet',
                style: GoogleFonts.nunito(
                    color: FairyTheme.goldDark,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Quick add logic ────────────────────────────────────────────

  void _addFromController(BuildContext context) {
    final ml = int.tryParse(_mlController.text.trim());
    if (ml != null && ml > 0) {
      context.read<WaterProvider>().addMl(ml);
      _mlController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _deleteEntry(BuildContext context, WaterProvider water, int id) async {
    final progressBefore = water.progress;
    await water.deleteEntry(id);
    
    // Check if we dropped below 1.0 progress
    if (progressBefore >= 1.0 && water.progress < 1.0) {
      final prefs = context.read<PreferencesProvider>();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      await prefs.revokeWaterReward(todayStr);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('⚠️ Su hedefine düştüğün için 5 Sihir Tozu geri alındı.'),
            backgroundColor: FairyTheme.dustyRose,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────

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
          child: Consumer<WaterProvider>(
            builder: (context, water, _) {
              return Column(
                children: [
                  _buildAppBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildJar(water),
                          const SizedBox(height: 16),
                          _buildWeeklyStats(water),
                          const SizedBox(height: 16),
                          _buildBonusChips(water),
                          const SizedBox(height: 16),
                          _buildQuickAdd(context),
                          const SizedBox(height: 16),
                          _buildSettings(context, water),
                          const SizedBox(height: 16),
                          _buildEntriesList(context, water),
                          const SizedBox(height: 16),
                          _buildStatsButton(context, water),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Padding(
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
              const Text('💧', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text('Su Takibi',
                  style: GoogleFonts.dancingScript(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: FairyTheme.cream)),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ── Jar visual ─────────────────────────────────────────────────

  Widget _buildJar(WaterProvider water) {
    final progress = water.progress.clamp(0.0, 1.0);
    final isDoubleOver = water.progress >= 2.0;
    final isGoalMet = water.progress >= 1.0;

    return Container(
      decoration: FairyTheme.parchmentCard(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 180,
            decoration: BoxDecoration(
              color: FairyTheme.mintLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: isGoalMet ? FairyTheme.gold : FairyTheme.mint,
                  width: 2.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17.5),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      height: 180 * progress,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isDoubleOver
                              ? [
                                  const Color(0xFFE8A0B0),
                                  FairyTheme.berryPink,
                                ]
                              : isGoalMet
                                  ? [
                                      FairyTheme.gold.withOpacity(0.4),
                                      FairyTheme.mint
                                    ]
                                  : [FairyTheme.mintLight, FairyTheme.mint],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isDoubleOver ? '🌊' : isGoalMet ? '🌟' : '🧚',
                            style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 4),
                        Text(
                          '${(water.progress * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: FairyTheme.inkBrown),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${water.todayTotalMl} ml',
            style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDoubleOver
                    ? FairyTheme.berryPink
                    : isGoalMet
                        ? FairyTheme.leafGreen
                        : FairyTheme.inkBrown),
          ),
          Text(
            'Hedef: ${water.adjustedGoalMl} ml',
            style:
                GoogleFonts.nunito(fontSize: 14, color: FairyTheme.medBrown),
          ),
          if (isGoalMet) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: FairyTheme.leafGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: FairyTheme.leafGreen.withOpacity(0.4)),
              ),
              child: Text('🎉 Günlük hedefine ulaştın!',
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: FairyTheme.leafGreen)),
            ),
          ],
        ],
      ),
    );
  }

  // ── Bonus chips ────────────────────────────────────────────────

  Widget _buildBonusChips(WaterProvider water) {
    final hasBonus =
        water.temperatureBonus > 0 || water.activityBonus > 0;
    if (!hasBonus) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: FairyTheme.parchmentCard(
          color: FairyTheme.parchment.withOpacity(0.9)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('✨ Ekstra İhtiyaç',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: FairyTheme.inkBrown)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (water.temperatureBonus > 0)
                _buildChip(
                    '🌡️ ${water.temperatureCelsius}°C sıcaklık',
                    '+${water.temperatureBonus} ml',
                    FairyTheme.dustyRose),
              if (water.activityBonus > 0)
                _buildChip(
                    '🏃 ${water.activityLevel.label}',
                    '+${water.activityBonus} ml',
                    FairyTheme.lavender),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style:
                  GoogleFonts.nunito(fontSize: 12, color: FairyTheme.inkBrown)),
          const SizedBox(width: 6),
          Text(value,
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: FairyTheme.inkBrown)),
        ],
      ),
    );
  }

  // ── Quick add (TextField + Ekle butonu) ───────────────────────

  Widget _buildQuickAdd(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: FairyTheme.parchmentCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💧 Su Ekle',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: FairyTheme.inkBrown)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _mlController,
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => _addFromController(context),
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: FairyTheme.inkBrown,
                  ),
                  decoration: InputDecoration(
                    hintText: 'ml miktarı gir...',
                    hintStyle: GoogleFonts.nunito(
                      color: FairyTheme.lightBrown.withOpacity(0.6),
                      fontSize: 14,
                    ),
                    suffixText: 'ml',
                    suffixStyle: GoogleFonts.nunito(
                      color: FairyTheme.medBrown,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: FairyTheme.mintLight.withOpacity(0.5),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: FairyTheme.mint.withOpacity(0.5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: FairyTheme.mint.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: FairyTheme.mint, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _addFromController(context),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: FairyTheme.mint,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: FairyTheme.mint.withOpacity(0.5),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('💧', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        'Ekle',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: FairyTheme.inkBrown,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Weekly stats bar chart ─────────────────────────────────────

  Widget _buildWeeklyStats(WaterProvider water) {
    final totals = water.weeklyTotals;
    if (totals.isEmpty) return const SizedBox.shrink();

    final goal = water.adjustedGoalMl;
    final maxVal = totals.values.fold<int>(goal, (m, v) => v > m ? v : m);
    final now = DateTime.now();

    // Build ordered list of last 7 days
    final days = List.generate(7, (i) {
      final d = DateTime(now.year, now.month, now.day - 6 + i);
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      return (date: d, key: key, ml: totals[key] ?? 0);
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: FairyTheme.parchmentCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('📈 Bu Hafta',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: FairyTheme.inkBrown)),
              const Spacer(),
              Text('Hedef: $goal ml',
                  style: GoogleFonts.nunito(
                      fontSize: 11, color: FairyTheme.lightBrown)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: days.map((d) {
              final isToday = d.date.day == now.day &&
                  d.date.month == now.month &&
                  d.date.year == now.year;
              final ratio = maxVal > 0 ? d.ml / maxVal : 0.0;
              final barHeight = 64.0 * ratio;

              Color barColor;
              if (d.ml == 0) {
                barColor = FairyTheme.parchmentDark;
              } else if (d.ml >= goal * 2) {
                barColor = FairyTheme.berryPink;
              } else if (d.ml >= goal) {
                barColor = FairyTheme.leafGreen;
              } else {
                barColor = FairyTheme.mint;
              }

              return Expanded(
                child: Column(
                  children: [
                    // ml label on top
                    if (d.ml > 0)
                      Text(
                        d.ml >= 1000
                            ? '${(d.ml / 1000).toStringAsFixed(1)}L'
                            : '${d.ml}',
                        style: GoogleFonts.nunito(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: barColor,
                        ),
                      )
                    else
                      const SizedBox(height: 10),
                    const SizedBox(height: 2),
                    // Bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      height: barHeight.clamp(4.0, 64.0),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(6),
                        border: isToday
                            ? Border.all(color: FairyTheme.goldDark, width: 1.5)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Day label
                    Text(
                      DateFormat('E', 'tr').format(d.date),
                      style: GoogleFonts.nunito(
                        fontSize: 9,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                        color: isToday ? FairyTheme.inkBrown : FairyTheme.lightBrown,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          // Legend
          Row(
            children: [
              _legend(FairyTheme.mint, 'İçildi'),
              const SizedBox(width: 10),
              _legend(FairyTheme.leafGreen, 'Hedef ✓'),
              const SizedBox(width: 10),
              _legend(FairyTheme.berryPink, '2x Hedef'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.nunito(
                fontSize: 9,
                color: FairyTheme.lightBrown,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ── Stats page button ──────────────────────────────────────────

  Widget _buildStatsButton(BuildContext context, WaterProvider water) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              WaterStatsScreen(adjustedGoalMl: water.adjustedGoalMl),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: FairyTheme.parchment,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FairyTheme.goldDark.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: FairyTheme.inkBrown.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📊', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Text('Tüm Girdileri Gör',
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: FairyTheme.inkBrown)),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: FairyTheme.lightBrown),
          ],
        ),
      ),
    );
  }

  // ── Settings ───────────────────────────────────────────────────

  Widget _buildSettings(BuildContext context, WaterProvider water) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: FairyTheme.parchmentCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⚙️ Ayarlar',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: FairyTheme.inkBrown)),
          const SizedBox(height: 14),

          // Goal
          _buildSettingRow(
            icon: '🎯',
            label: 'Günlük Temel Hedef',
            valueText: '${water.baseGoalMl} ml',
            onTap: () => _showGoalDialog(context, water.baseGoalMl),
          ),
          const Divider(height: 20, color: Color(0x30D4A853)),

          // Temperature slider
          Row(
            children: [
              const Text('🌡️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text('Hava Sıcaklığı',
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: FairyTheme.inkBrown)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: FairyTheme.dustyRose.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${water.temperatureCelsius}°C',
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: FairyTheme.inkBrown)),
              ),
            ],
          ),
          Slider(
            value: water.temperatureCelsius.toDouble(),
            min: 0,
            max: 50,
            divisions: 50,
            activeColor: FairyTheme.dustyRose,
            inactiveColor: FairyTheme.parchmentDark,
            onChanged: (v) => water.setTemperature(v.round()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0°C',
                  style: GoogleFonts.nunito(
                      fontSize: 10, color: FairyTheme.lightBrown)),
              if (water.temperatureBonus > 0)
                Text('+${water.temperatureBonus} ml ekstra',
                    style: GoogleFonts.nunito(
                        fontSize: 10,
                        color: FairyTheme.berryPink,
                        fontWeight: FontWeight.w700)),
              Text('50°C',
                  style: GoogleFonts.nunito(
                      fontSize: 10, color: FairyTheme.lightBrown)),
            ],
          ),

          const Divider(height: 20, color: Color(0x30D4A853)),

          // Activity level
          Row(
            children: [
              const Text('🏃', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text('Aktivite Düzeyi',
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: FairyTheme.inkBrown)),
            ],
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.6,
            children: ActivityLevel.values.map((level) {
              final isSelected = water.activityLevel == level;
              return GestureDetector(
                onTap: () => water.setActivityLevel(level),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? FairyTheme.lavender.withOpacity(0.7)
                        : FairyTheme.parchment,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? FairyTheme.lavenderDark
                          : FairyTheme.gold.withOpacity(0.4),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(level.label,
                          style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: FairyTheme.inkBrown)),
                      if (level.extraMl > 0)
                        Text('+${level.extraMl} ml',
                            style: GoogleFonts.nunito(
                                fontSize: 9,
                                color: isSelected ? FairyTheme.inkBrown : FairyTheme.cream,
                                fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required String icon,
    required String label,
    required String valueText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: FairyTheme.inkBrown)),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: FairyTheme.parchment,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: FairyTheme.goldDark.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Text(valueText,
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: FairyTheme.inkBrown)),
                const SizedBox(width: 4),
                Icon(Icons.edit_rounded,
                    size: 12, color: FairyTheme.lightBrown),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Entries list ───────────────────────────────────────────────

  Widget _buildEntriesList(BuildContext context, WaterProvider water) {
    if (water.todayEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: FairyTheme.parchmentCard(),
        child: Center(
          child: Column(
            children: [
              const Text('💧', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text('Bugün henüz su içilmedi',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 14,
                      color: FairyTheme.lightBrown,
                      fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: FairyTheme.parchmentCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text('📋 Bugünün Kayıtları',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: FairyTheme.inkBrown)),
          ),
          ...water.todayEntries
              .map((entry) => _buildEntryTile(context, water, entry)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildEntryTile(
      BuildContext context, WaterProvider water, WaterEntry entry) {
    return Dismissible(
      key: Key('water_entry_${entry.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: FairyTheme.berryPink.withOpacity(0.3),
        child: Icon(Icons.delete_outline_rounded,
            color: FairyTheme.berryPink),
      ),
      onDismissed: (_) => _deleteEntry(context, water, entry.id!),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: FairyTheme.mintLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: FairyTheme.mint.withOpacity(0.6)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: FairyTheme.mint.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('💧', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${entry.amountMl} ml',
                style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: FairyTheme.inkBrown),
              ),
            ),
            Text(
              DateFormat('HH:mm').format(entry.createdAt),
              style: GoogleFonts.nunito(
                  fontSize: 12, color: FairyTheme.lightBrown),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _deleteEntry(context, water, entry.id!),
              child: Icon(Icons.close_rounded,
                  size: 16,
                  color: FairyTheme.lightBrown.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
