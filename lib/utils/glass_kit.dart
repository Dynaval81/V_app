import 'package:flutter/material.dart';
import 'dart:ui';

class GlassKit {
  static Widget liquidGlass({required Widget child, double radius = 20, double opacity = 0.1}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.2),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(opacity + 0.05),
                Colors.white.withOpacity(opacity),
              ],
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
