import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesProvider with ChangeNotifier {
  static const _keyMotivation = 'pref_motivation_text';
  static const _defaultMotivation = 'Kendine zaman ayır! ✨';

  static const _keyPixieDust = 'pref_pixie_dust';
  static const _keyGardenLevel = 'pref_garden_level';
  static const _keyLastWaterReward = 'pref_last_water_reward';
  static const _keyAppTheme = 'pref_app_theme';

  String _motivationText = _defaultMotivation;
  int _pixieDust = 0;
  int _gardenLevel = 1;
  String _lastWaterRewardDate = '';
  ThemeType _appTheme = ThemeType.fairyDay;

  String get motivationText => _motivationText;
  int get pixieDust => _pixieDust;
  int get gardenLevel => _gardenLevel;
  ThemeType get appTheme => _appTheme;

  PreferencesProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _motivationText = prefs.getString(_keyMotivation) ?? _defaultMotivation;
    _pixieDust = prefs.getInt(_keyPixieDust) ?? 0;
    _gardenLevel = prefs.getInt(_keyGardenLevel) ?? 1;
    _lastWaterRewardDate = prefs.getString(_keyLastWaterReward) ?? '';
    _appTheme = ThemeType.values[prefs.getInt(_keyAppTheme) ?? 0];
    notifyListeners();
  }

  Future<void> setAppTheme(ThemeType theme) async {
    _appTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAppTheme, theme.index);
    notifyListeners();
  }

  Future<void> setMotivationText(String text) async {
    _motivationText = text.trim().isEmpty ? _defaultMotivation : text.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMotivation, _motivationText);
    notifyListeners();
  }

  Future<void> addPixieDust(int amount) async {
    _pixieDust += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPixieDust, _pixieDust);
    notifyListeners();
  }

  Future<bool> spendPixieDust(int amount) async {
    if (_pixieDust >= amount) {
      _pixieDust -= amount;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyPixieDust, _pixieDust);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> removePixieDust(int amount) async {
    _pixieDust -= amount;
    if (_pixieDust < 0) _pixieDust = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPixieDust, _pixieDust);
    notifyListeners();
  }

  Future<void> levelUpGarden() async {
    _gardenLevel++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyGardenLevel, _gardenLevel);
    notifyListeners();
  }

  /// Checks if the user already got a reward for drinking water today.
  /// If not, updates the date and returns true (granting reward).
  Future<bool> claimWaterReward(String dateStr) async {
    if (_lastWaterRewardDate == dateStr) {
      return false; // Already claimed today
    }
    _lastWaterRewardDate = dateStr;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastWaterReward, _lastWaterRewardDate);
    return true;
  }

  /// Revokes the reward if the user undrinks below the goal on the same day.
  Future<void> revokeWaterReward(String dateStr) async {
    if (_lastWaterRewardDate == dateStr) {
      _lastWaterRewardDate = '';
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyLastWaterReward);
      await removePixieDust(5); // Take back 5 Pixie Dust
    }
  }
}

enum ThemeType {
  fairyDay,
  nightForest,
  autumnMagic,
}
