import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_colors.dart';
import 'app_theme.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
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
