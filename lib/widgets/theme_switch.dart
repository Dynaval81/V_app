import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ThemeSwitch extends StatefulWidget {
  @override
  _ThemeSwitchState createState() => _ThemeSwitchState();
}

class _ThemeSwitchState extends State<ThemeSwitch> {
  bool _isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        'Dark Mode',
        style: TextStyle(
          color: _isDarkMode ? AppColors.primaryText : AppColors.lightPrimaryText,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        'Switch between light and dark themes',
        style: TextStyle(
          color: _isDarkMode ? AppColors.secondaryText : AppColors.lightSecondaryText,
          fontSize: 12,
        ),
      ),
      value: _isDarkMode,
      onChanged: (value) {
        setState(() {
          _isDarkMode = value;
        });
        // TODO: Implement actual theme switching
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isDarkMode ? 'Dark mode enabled' : 'Light mode enabled'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      activeColor: AppColors.primaryBlue,
      secondary: Icon(
        _isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: _isDarkMode ? AppColors.primaryText : AppColors.lightPrimaryText,
      ),
    );
  }
}
