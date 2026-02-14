import 'package:flutter/material.dart';

/// 🎨 HAI3 Design System for V-Talk Beta
/// Based on https://github.com/HAI3org/HAI3 design tokens
/// Minimalist design with maximum content, minimum chrome

class AppColors {
  // 🎯 Primary Colors (HAI3 Minimalist)
  static const primary = Color(0xFF00A3FF);      // Bright blue accent
  static const primaryVariant = Color(0xFF0090E0);  // Darker blue
  static const secondary = Color(0xFF00D4FF);      // Light blue accent
  
  // 🌑 Background Colors (HAI3 Dark Theme)
  static const background = Color(0xFF000000);      // Pure black
  static const surface = Color(0xFF1A1A1A);        // Dark gray
  static const cardBackground = Color(0xFF2A2A2A);   // Medium gray
  
  // 📝 Text Colors (HAI3 High Contrast)
  static const onPrimary = Color(0xFF000000);      // Black on primary
  static const onBackground = Color(0xFFFFFFFF);    // White on background
  static const onSurface = Color(0xFFFFFFFF);      // White on surface
  static const onSurfaceVariant = Color(0xFF666666); // Muted gray
  
  // 🚨 Status Colors (HAI3 Semantic)
  static const error = Color(0xFFFF3B30);         // Red accent
  static const success = Color(0xFF30D158);        // Green accent
  static const warning = Color(0xFFFF9500);        // Orange accent
  static const info = Color(0xFF007AFF);           // Blue accent
  
  // 🌈 Gradient Colors (HAI3 Subtle)
  static const primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const surfaceGradient = LinearGradient(
    colors: [surface, cardBackground],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppSpacing {
  // 📏 8px Grid System (HAI3 Standard)
  static const xs = 4.0;   // 0.5rem
  static const sm = 8.0;   // 1rem
  static const md = 16.0;  // 2rem
  static const lg = 24.0;  // 3rem
  static const xl = 32.0;  // 4rem
  static const xxl = 48.0; // 6rem
  static const xxxl = 64.0; // 8rem
  
  // 🎯 Component-specific spacing
  static const componentPadding = 16.0;
  static const screenPadding = 24.0;
  static const cardPadding = 20.0;
  static const inputPadding = 16.0;
  static const buttonPadding = 24.0;
}

class AppTextStyles {
  // 📝 Typography Scale (HAI3 Minimalist)
  static const h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.3,
  );
  
  static const h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );
  
  static const h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );
  
  static const bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.4,
  );
  
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.3,
  );
  
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.25,
    height: 1.2,
  );
  
  static const input = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.4,
  );
}

class AppBorderRadius {
  // 🔄 Border Radius (HAI3 Consistent)
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const round = 999.0; // For circular elements
  
  // 🎯 Component-specific
  static const button = 12.0;
  static const card = 16.0;
  static const input = 12.0;
  static const chip = 8.0;
  static const dialog = 16.0;
}

class AppShadows {
  // 🌑 Elevation (HAI3 Subtle)
  static const sm = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );
  
  static const md = BoxShadow(
    color: Color(0x33000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );
  
  static const lg = BoxShadow(
    color: Color(0x4D000000),
    blurRadius: 16,
    offset: Offset(0, 8),
  );
  
  static const xl = BoxShadow(
    color: AppColors.primary,
    blurRadius: 20,
    offset: Offset(0, 4),
  );
  
  // 🎯 Component-specific
  static const card = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  );
  
  static const button = BoxShadow(
    color: Color(0x3300A3FF),
    blurRadius: 8,
    offset: Offset(0, 4),
  );
}

class AppTheme {
  // 🎨 HAI3 Dark Theme (Primary)
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // 🎯 Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryVariant,
      secondary: AppColors.secondary,
      background: AppColors.background,
      surface: AppColors.surface,
      onPrimary: AppColors.onPrimary,
      onBackground: AppColors.onBackground,
      onSurface: AppColors.onSurface,
      error: AppColors.error,
    ),
    
    // 📝 Text Theme
    textTheme: TextTheme(
      displayLarge: AppTextStyles.h1.copyWith(color: AppColors.onSurface),
      displayMedium: AppTextStyles.h2.copyWith(color: AppColors.onSurface),
      headlineLarge: AppTextStyles.h3.copyWith(color: AppColors.onSurface),
      headlineMedium: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
      bodyLarge: AppTextStyles.body.copyWith(color: AppColors.onSurface),
      bodyMedium: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
      labelLarge: AppTextStyles.button.copyWith(color: AppColors.onPrimary),
    ),
    
    // 🎨 AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
      iconTheme: const IconThemeData(
        color: AppColors.onSurface,
        size: 24,
      ),
    ),
    
    // 🃏 Card Theme
    cardTheme: CardTheme(
      color: AppColors.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.card),
      ),
      shadowColor: Colors.transparent,
    ),
    
    // 🔘 Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.button),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPadding,
          vertical: AppSpacing.md,
        ),
        textStyle: AppTextStyles.button,
      ),
    ),
    
    // 📝 Input Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.input),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.input),
        borderSide: BorderSide(
          color: AppColors.onSurface.withOpacity(0.2),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.input),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.input),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.all(AppSpacing.inputPadding),
      labelStyle: AppTextStyles.input.copyWith(color: AppColors.onSurfaceVariant),
      hintStyle: AppTextStyles.input.copyWith(
        color: AppColors.onSurfaceVariant.withOpacity(0.7),
      ),
    ),
    
    // 🧭 Bottom Navigation Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: AppTextStyles.caption.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTextStyles.caption.copyWith(
        color: AppColors.onSurfaceVariant,
        fontWeight: FontWeight.w400,
      ),
    ),
    
    // 🎯 Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.onSurface,
      size: 24,
    ),
    
    // 📏 Divider Theme
    dividerTheme: DividerThemeData(
      color: AppColors.onSurface.withOpacity(0.1),
      thickness: 1,
      space: 1,
    ),
    
    // 🔄 Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.surface,
      circularTrackColor: AppColors.surface,
    ),
    
    // 🎯 Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return AppColors.onSurface.withOpacity(0.6);
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary.withOpacity(0.5);
        }
        return AppColors.onSurface.withOpacity(0.3);
      }),
    ),
    
    // ☑️ Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(AppColors.onPrimary),
      side: BorderSide(
        color: AppColors.onSurface.withOpacity(0.6),
        width: 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xs),
      ),
    ),
    
    // 🎯 Radio Theme
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return AppColors.onSurface.withOpacity(0.6);
      }),
    ),
    
    // 🎯 Dialog Theme
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.dialog),
      ),
      titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.onSurface),
      contentTextStyle: AppTextStyles.body.copyWith(color: AppColors.onSurface),
    ),
    
    // 🎯 SnackBar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surface,
      contentTextStyle: AppTextStyles.body.copyWith(color: AppColors.onSurface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),
  );
  
  // 🌞 HAI3 Light Theme (Secondary)
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryVariant,
      secondary: AppColors.secondary,
      background: Color(0xFFFFFFFF),
      surface: Color(0xFFF5F5F5),
      onPrimary: AppColors.onPrimary,
      onBackground: Color(0xFF000000),
      onSurface: Color(0xFF000000),
      error: AppColors.error,
    ),
    
    // 📝 Text Theme (Light)
    textTheme: TextTheme(
      displayLarge: AppTextStyles.h1.copyWith(color: AppColors.onBackground),
      displayMedium: AppTextStyles.h2.copyWith(color: AppColors.onBackground),
      headlineLarge: AppTextStyles.h3.copyWith(color: AppColors.onBackground),
      headlineMedium: AppTextStyles.h4.copyWith(color: AppColors.onBackground),
      bodyLarge: AppTextStyles.body.copyWith(color: AppColors.onBackground),
      bodyMedium: AppTextStyles.bodySmall.copyWith(color: AppColors.onBackground),
      labelLarge: AppTextStyles.button.copyWith(color: AppColors.onPrimary),
    ),
    
    // 🎨 Other themes inherit from dark with light adaptations
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.h4.copyWith(color: AppColors.onBackground),
      iconTheme: const IconThemeData(
        color: AppColors.onBackground,
        size: 24,
      ),
    ),
    
    cardTheme: CardTheme(
      color: const Color(0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.card),
      ),
      shadowColor: Colors.transparent,
    ),
    
    // 🎯 Rest of the themes follow the same pattern...
  );
}
