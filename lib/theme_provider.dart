import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  bool _isInitialized = false;

  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  ThemeData get currentTheme {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFF1A1A2E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF252541),
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.white54,
      type: BottomNavigationBarType.fixed,
    ),
  );

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF252541),
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.white54,
      type: BottomNavigationBarType.fixed,
    ),
  );

  Future<void> initializeTheme() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('is_dark_mode') ?? true;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // Если произошла ошибка, используем темную тему по умолчанию
      _isDarkMode = true;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', _isDarkMode);
    } catch (e) {
      // Продолжаем работу даже если не удалось сохранить
    }
    
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', _isDarkMode);
    } catch (e) {
      // Продолжаем работу даже если не удалось сохранить
    }
    
    notifyListeners();
  }
}
