import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vtalk_app/presentation/screens/auth/login_screen.dart';
import 'package:vtalk_app/presentation/widgets/organisms/main_nav_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    try {
      await Future.delayed(const Duration(milliseconds: 2500));
      if (!mounted) return;
      
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      
      if (!mounted) return;
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => isLoggedIn ? const MainNavShell() : const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 1.0, end: 1.1),
              duration: const Duration(seconds: 2),
              builder: (context, double scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF2196F3),
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        'assets/images/logo_bnb.png',
                        height: 100,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'V-TALK',
              style: TextStyle(
                fontWeight: FontWeight.w200,
                letterSpacing: 12.0,
                fontSize: 28,
                color: Color(0xFF2196F3),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Next Gen Messaging',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w300,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/hai_3_dark.png',
                  height: 20,
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}