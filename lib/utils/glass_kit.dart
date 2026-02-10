import 'package:flutter/material.dart';
import 'dart:ui';

class GlassKit {
  static Widget liquidGlass({
    required Widget child, 
    double radius = 20, 
    double? opacity,
    bool isDark = true,
    bool useBlur = true,  // ✅ Новый параметр для контроля блюра
  }) {
    // Выбираем базовый цвет стекла в зависимости от темы
    Color glassColor = isDark 
        ? Colors.black.withOpacity(opacity ?? 0.2) 
        : Colors.white.withOpacity(opacity ?? 0.2);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: useBlur 
          ? ImageFilter.blur(sigmaX: 12, sigmaY: 12)
          : ImageFilter.blur(sigmaX: 0, sigmaY: 0),  // ✅ Отключаем блюр для производительности
        child: Container(
          decoration: BoxDecoration(
            color: glassColor, // Теперь цвет не будет спорить с темой
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black12, 
              width: 1.0
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  static BoxDecoration mainBackground(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark 
          ? [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)]
          : [Color(0xFFE0EAFC), Color(0xFFCFDEF3)], // Светлая "ледяная" тема
      ),
    );
  }
}
