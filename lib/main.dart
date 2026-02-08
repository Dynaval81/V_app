import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth_wrapper.dart';
import 'theme/theme_manager.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(VtalkApp());
}

class VtalkApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeManager(),
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'Vtalk',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeManager.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: AuthWrapper(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}