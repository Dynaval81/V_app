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
        ),
      ),
      value: _isDarkMode,
      onChanged: (value) {
        setState(() {
          _isDarkMode = value;
        });
        // TODO: Implement theme switching logic
      },
      activeColor: AppColors.primaryBlue,
    );
  }
}
