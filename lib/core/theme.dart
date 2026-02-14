import 'package:flutter/material.dart';

class AppTheme {
  // 🚨 Глобальный акцентный цвет V-Talk (ртутный голубой)
  static const Color primaryColor = Color(0xFF00B2FF);
  static const Color primaryVariant = Color(0xFF0090E0);
  static const Color secondaryColor = Color(0xFF00D4FF);
  
  // 🚨 Цветовая палитра
  static const Color backgroundColor = Color(0xFF0A0A0A);
  static const Color surfaceColor = Color(0xFF1A1A1A);
  static const Color cardColor = Color(0xFF2A2A2A);
  
  // 🚨 Текстовые цвета
  static const Color onPrimary = Color(0xFF000000);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onBackground = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFFFFFFF);
  
  // 🚨 Статусные цвета
  static const Color successColor = Color(0xFF00C853);
  static const Color errorColor = Color(0xFFFF1744);
  static const Color warningColor = Color(0xFFFF9100);
  
  // 🚨 Градиенты
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 🚨 Темная тема (основная)
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // 🚨 Основные цвета
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      primaryContainer: primaryVariant,
      secondary: secondaryColor,
      background: backgroundColor,
      surface: surfaceColor,
      onPrimary: onPrimary,
      onSecondary: onSecondary,
      onBackground: onBackground,
      onSurface: onSurface,
      error: errorColor,
    ),
    
    // 🚨 Тема для AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: onSurface,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
      iconTheme: IconThemeData(
        color: onSurface,
        size: 24,
      ),
    ),
    
    // 🚨 Тема для карточек
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.black.withOpacity(0.3),
    ),
    
    // 🚨 Тема для кнопок
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // 🚨 Тема для текстовых полей
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 2,
        ),
      ),
      labelStyle: const TextStyle(
        color: onSurface,
        fontSize: 14,
      ),
      hintStyle: TextStyle(
        color: onSurface.withOpacity(0.6),
        fontSize: 14,
      ),
    ),
    
    // 🚨 Тема для BottomNavigationBar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: onSurface,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    
    // 🚨 Текстовые стили
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: onSurface,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: onSurface,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.25,
      ),
      headlineLarge: TextStyle(
        color: onSurface,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      headlineMedium: TextStyle(
        color: onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      bodyLarge: TextStyle(
        color: onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        color: onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      labelLarge: TextStyle(
        color: onPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25,
      ),
    ),
    
    // 🚨 Иконки
    iconTheme: const IconThemeData(
      color: onSurface,
      size: 24,
    ),
    
    // 🚨 Разделители
    dividerTheme: DividerThemeData(
      color: onSurface.withOpacity(0.12),
      thickness: 1,
      space: 1,
    ),
    
    // 🚨 Индикаторы прогресса
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
      linearTrackColor: surfaceColor,
      circularTrackColor: surfaceColor,
    ),
    
    // 🚨 Переключатели
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return onSurface.withOpacity(0.6);
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor.withOpacity(0.5);
        }
        return onSurface.withOpacity(0.3);
      }),
    ),
    
    // 🚨 Чекбоксы
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(onPrimary),
      side: BorderSide(
        color: onSurface.withOpacity(0.6),
        width: 2,
      ),
    ),
    
    // 🚨 Радио кнопки
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return onSurface.withOpacity(0.6);
      }),
    ),
    
    // 🚨 Слайдеры
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryColor,
      inactiveTrackColor: onSurface.withOpacity(0.3),
      thumbColor: primaryColor,
      overlayColor: primaryColor.withOpacity(0.2),
      valueIndicatorColor: primaryColor,
      valueIndicatorTextStyle: const TextStyle(
        color: onPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // 🚨 Фаб кнопки
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: onPrimary,
      elevation: 6,
      shape: CircleBorder(),
    ),
    
    // 🚨 Чипы
    chipTheme: ChipThemeData(
      backgroundColor: surfaceColor,
      selectedColor: primaryColor.withOpacity(0.2),
      disabledColor: onSurface.withOpacity(0.12),
      labelStyle: const TextStyle(
        color: onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: const TextStyle(
        color: primaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      side: BorderSide(
        color: onSurface.withOpacity(0.3),
        width: 1,
      ),
    ),
    
    // 🚨 Диалоги
    dialogTheme: DialogTheme(
      backgroundColor: surfaceColor,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: const TextStyle(
        color: onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),
    
    // 🚨 Баннеры
    bannerTheme: MaterialBannerThemeData(
      backgroundColor: surfaceColor,
      contentTextStyle: const TextStyle(
        color: onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      leadingTextStyle: const TextStyle(
        color: onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
    
    // 🚨 Снэкбары
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceColor,
      contentTextStyle: const TextStyle(
        color: onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
    ),
  );
  
  // 🚨 Светлая тема (дополнительная)
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      primaryContainer: primaryVariant,
      secondary: secondaryColor,
      background: Color(0xFFF5F5F5),
      surface: Color(0xFFFFFFFF),
      onPrimary: onPrimary,
      onSecondary: onSecondary,
      onBackground: Color(0xFF000000),
      onSurface: Color(0xFF000000),
      error: errorColor,
    ),
    
    // 🚨 Остальные темы наследуются от темной с адаптацией
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFF000000),
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
      iconTheme: IconThemeData(
        color: Color(0xFF000000),
        size: 24,
      ),
    ),
    
    cardTheme: CardTheme(
      color: const Color(0xFFFFFFFF),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.black.withOpacity(0.1),
    ),
    
    // 🚨 Остальные компоненты адаптируются автоматически
  );
}
