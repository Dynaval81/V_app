import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'screens/tabs/chats_screen.dart';
import 'screens/tabs/vpn_screen.dart';
import 'screens/tabs/ai_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Сюда потом добавишь AuthProvider и ChatProvider
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

  // Тот самый ПОРЯДОК, который ты просил
  late final List<Widget> _screens = [
    const ChatsScreen(),      // 0 - Мессенджер (Первый)
    const VPNScreen(),        // 1 - VPN
    const AIScreen(),         // 2 - Vtalk AI
    DashboardScreen(onTabSwitch: _switchTab),   // 3 - Dashboard (Последний)
  ];

  @override
  void initState() {
    super.initState();
    // Инициализируем тему при старте
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ThemeProvider>(context, listen: false).initializeTheme();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Убираем appBar отсюда, он в каждом экране свой для Liquid Glass
      body: IndexedStack( // Используем IndexedStack, чтобы экраны не перезагружались
        index: _currentIndex,
        children: _screens,
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
