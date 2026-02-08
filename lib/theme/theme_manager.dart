import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import 'app_theme.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('is_dark_mode') ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveTheme();
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    await _saveTheme();
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', _isDarkMode);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  ThemeData getCurrentTheme() {
    return _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
  }

  Color getCurrentBackgroundColor() {
    return _isDarkMode ? AppColors.primaryBackground : AppColors.lightPrimaryBackground;
  }

  Color getCurrentCardColor() {
    return _isDarkMode ? AppColors.cardBackground : AppColors.lightCardBackground;
  }

  Color getCurrentTextColor() {
    return _isDarkMode ? AppColors.primaryText : AppColors.lightPrimaryText;
  }

  Color getCurrentSecondaryTextColor() {
    return _isDarkMode ? AppColors.secondaryText : AppColors.lightSecondaryText;
  }
}
