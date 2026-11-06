import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:serenity_diary/models/water_entry.dart';
import 'package:serenity_diary/repository/water_repository.dart';

/// Activity level with evidence-based extra water amounts.
///
/// Sources: ACSM, NHS guidelines:
///   - Sedentary (desk work, <30 min light walk): +0 ml
///   - Light     (30-60 min walk/yoga):           +350 ml
///   - Moderate  (1 hr gym / cycling):            +700 ml
///   - Intense   (2+ hr training / sport):        +1 000 ml
enum ActivityLevel {
  sedentary,
  light,
  moderate,
  intense;

  String get label {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Hareketsiz';
      case ActivityLevel.light:
        return 'Hafif Aktif';
      case ActivityLevel.moderate:
        return 'Orta Aktif';
      case ActivityLevel.intense:
        return 'Çok Aktif';
    }
  }

  String get description {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Masa başı, çok az hareket';
      case ActivityLevel.light:
        return '30-60 dk yürüyüş / yoga';
      case ActivityLevel.moderate:
        return '1 saat spor / bisiklet';
      case ActivityLevel.intense:
        return '2+ saat yoğun antrenman';
    }
  }

  /// Extra ml based on ACSM fluid replacement guidelines.
  int get extraMl {
    switch (this) {
      case ActivityLevel.sedentary:
        return 0;
      case ActivityLevel.light:
        return 350;
      case ActivityLevel.moderate:
        return 700;
      case ActivityLevel.intense:
        return 1000;
    }
  }
}

class WaterProvider with ChangeNotifier {
  static const _keyGoal = 'pref_water_goal_ml';
  static const _keyTemp = 'pref_water_temp_celsius';
  static const _keyActivity = 'pref_water_activity';

  // State
  List<WaterEntry> _todayEntries = [];
  int _baseGoalMl = 2000;
  int _temperatureCelsius = 22;
  ActivityLevel _activityLevel = ActivityLevel.sedentary;
  bool _isLoading = true;
  Map<String, int> _weeklyTotals = {};

  // Getters
  List<WaterEntry> get todayEntries => _todayEntries;
  int get baseGoalMl => _baseGoalMl;
  int get temperatureCelsius => _temperatureCelsius;
  ActivityLevel get activityLevel => _activityLevel;
  bool get isLoading => _isLoading;
  Map<String, int> get weeklyTotals => _weeklyTotals;

  int get todayTotalMl =>
      _todayEntries.fold(0, (sum, e) => sum + e.amountMl);

  /// Extra ml for temperature.
  ///
  /// Based on WHO / CDC guidelines:
  ///   < 25°C → +0 ml   (comfortable)
  ///   25-30°C → +250 ml (warm)
  ///   30-35°C → +500 ml (hot)
  ///   35-40°C → +750 ml (very hot)
  ///   ≥ 40°C  → +1 000 ml (extreme heat)
  int get temperatureBonus {
    if (_temperatureCelsius < 25) return 0;
    if (_temperatureCelsius < 30) return 250;
    if (_temperatureCelsius < 35) return 500;
    if (_temperatureCelsius < 40) return 750;
    return 1000;
  }

  int get activityBonus => _activityLevel.extraMl;

  /// The adjusted goal the user should aim for today.
  int get adjustedGoalMl => _baseGoalMl + temperatureBonus + activityBonus;

  /// Progress ratio — can exceed 1.0 (no hard cap).
  double get progress => todayTotalMl / adjustedGoalMl;

  WaterProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadPrefs();
    await _loadTodayEntries();
    await _loadWeeklyTotals();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _baseGoalMl = prefs.getInt(_keyGoal) ?? 2000;
    _temperatureCelsius = prefs.getInt(_keyTemp) ?? 22;
    _activityLevel =
        ActivityLevel.values[prefs.getInt(_keyActivity) ?? 0];
  }

  Future<void> _loadTodayEntries() async {
    _todayEntries = await WaterRepository.getEntriesForDate(DateTime.now());
  }

  Future<void> _loadWeeklyTotals() async {
    _weeklyTotals = await WaterRepository.getDailyTotals();
  }

  // ── Actions ──────────────────────────────────────────────────

  Future<void> addMl(int ml) async {
    if (ml <= 0) return;
    await WaterRepository.insert(
        WaterEntry(amountMl: ml, createdAt: DateTime.now()));
    await _loadTodayEntries();
    await _loadWeeklyTotals();
    notifyListeners();
  }

  Future<void> deleteEntry(int id) async {
    await WaterRepository.delete(id);
    await _loadTodayEntries();
    await _loadWeeklyTotals();
    notifyListeners();
  }

  Future<void> setGoal(int ml) async {
    _baseGoalMl = ml.clamp(500, 10000);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyGoal, _baseGoalMl);
    notifyListeners();
  }

  Future<void> setTemperature(int celsius) async {
    _temperatureCelsius = celsius.clamp(0, 55);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTemp, _temperatureCelsius);
    notifyListeners();
  }

  Future<void> setActivityLevel(ActivityLevel level) async {
    _activityLevel = level;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyActivity, level.index);
    notifyListeners();
  }
}
