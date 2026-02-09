import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'screens/chats_screen_working.dart';
import 'screens/tabs/vpn_screen.dart';
import 'screens/tabs/ai_screen.dart';
import 'screens/dashboard_screen_working.dart';
import 'screens/chat_room_screen_working.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
                  builder: (_) => ChatRoomScreen(chatId: 1),
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

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ThemeProvider>(context, listen: false).initializeTheme();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const ChatsScreen(),
          const VPNScreen(),
          const AIScreen(),
          DashboardScreen(onTabSwitch: _switchTab),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF252541).withOpacity(0.8),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.vpn_lock), label: 'VPN'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Vtalk AI'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
        ],
      ),
    );
  }
}
