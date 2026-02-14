import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'providers/user_provider.dart';
import 'screens/tabs/chats_screen.dart';
import 'screens/tabs/vpn_screen.dart';
import 'screens/tabs/ai_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/chat_room_screen.dart';
import 'screens/auth_screen.dart';
import 'widgets/premium_guard.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const VtalkApp(),
    ),
  );
}

class VtalkApp extends StatelessWidget {
  const VtalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeProvider.currentTheme,
          home: const MainScreen(),
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/chat':
                return CupertinoPageRoute(
                  builder: (_) => ChatRoomScreen(chatId: '1'),
                  title: 'Chat',
                );
              case '/settings':
                return CupertinoPageRoute(
                  builder: (_) => DashboardScreen(onTabSwitch: (index) {}),
                  title: 'Settings',
                );
              default:
                return CupertinoPageRoute(
                  builder: (_) => const MainScreen(),
                  title: 'Vtalk',
                );
            }
          },
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Получаем состояние темы из ThemeProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load user data if not already present
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user == null && !userProvider.isLoading) {
        userProvider.refreshUserData();
      }
    });
  }

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ПОДПИСЫВАЕМСЯ НА ИЗМЕНЕНИЯ:
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // 🚨 ПРОВЕРКА АВТОРИЗАЦИИ - если нет пользователя, показываем экран логина
    if (userProvider.user == null && !userProvider.isLoading) {
      return const AuthScreen(); // Импортируем AuthScreen
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const ChatsScreen(),
          PremiumGuard(child: const AIScreen()),
          PremiumGuard(child: const VPNScreen()),
          DashboardScreen(onTabSwitch: _switchTab),
        ],
      ),
      bottomNavigationBar: Container(
        // Динамический цвет фона
        color: isDark ? const Color(0xFF252541) : const Color(0xFFF5F5F5),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent, // Чтобы видеть цвет контейнера
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: isDark ? Colors.white54 : Colors.black38, // Динамические цвета иконок
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
            BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Vtalk AI'),
            BottomNavigationBarItem(icon: Icon(Icons.vpn_lock), label: 'VPN'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
          ],
        ),
      ),
    );
  }
}
