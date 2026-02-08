import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../theme/theme_manager.dart';

class ThemeSwitch extends StatefulWidget {
  @override
  _ThemeSwitchState createState() => _ThemeSwitchState();
}

class _ThemeSwitchState extends State<ThemeSwitch> {
  final ThemeManager _themeManager = ThemeManager();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeManager,
      builder: (context, child) {
        return SwitchListTile(
          title: Text(
            'Dark Mode',
            style: TextStyle(
              color: _themeManager.isDarkMode ? AppColors.primaryText : AppColors.lightPrimaryText,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            'Switch between light and dark themes',
            style: TextStyle(
              color: _themeManager.isDarkMode ? AppColors.secondaryText : AppColors.lightSecondaryText,
              fontSize: 12,
            ),
          ),
          value: _themeManager.isDarkMode,
          onChanged: (value) {
            _themeManager.setTheme(value);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(value ? 'Dark mode enabled' : 'Light mode enabled'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          activeColor: AppColors.primaryBlue,
          secondary: Icon(
            _themeManager.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: _themeManager.isDarkMode ? AppColors.primaryText : AppColors.lightPrimaryText,
          ),
        );
      },
    );
  }
}
