import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
// ВАЖНО: Проверь пути к этим файлам в своем проекте, SWE должен их подправить если что
import 'package:vtalk_app/presentation/screens/auth/login_screen.dart';
import 'package:vtalk_app/presentation/widgets/organisms/main_nav_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  Future<void> _startTimer() async {
    // 2.5 секунды дзена
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            isLoggedIn ? const MainNavShell() : const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // Центральный блок: Лого и Слоган
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.95, end: 1.05),
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  builder: (context, double scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        // ГЕОМЕТРИЯ HAI3 (24.0)
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/images/logo_bnb.png',
                          height: 120,
                          // Если нужно подкрасить в синий
                          color: const Color(0xFF2196F3),
                          colorBlendMode: BlendMode.srcIn,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'V-TALK',
                  style: TextStyle(
                    fontWeight: FontWeight.w200,
                    letterSpacing: 12.0,
                    fontSize: 32,
                    color: Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Next Gen Messaging',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Футер: Powered by HAI3
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ИСПОЛЬЗУЕМ Image.asset ВМЕСТО SvgPicture
                Image.asset(
                  'assets/images/hai_3_dark.png',
                  height: 18,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Powered by HAI3 | Zen Canons Applied',
                  style: TextStyle(
                    fontWeight: FontWeight.w200,
                    fontSize: 10,
                    letterSpacing: 2.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}