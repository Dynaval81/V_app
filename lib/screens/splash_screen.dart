import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/widgets/organisms/main_nav_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print('HAI3_DEBUG: Splash started');
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      print('HAI3_DEBUG: Navigating now. User: ${user?.uid}');
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => user == null ? LoginScreen() : MainNavShell()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Main content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with blue color filter
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          const Color(0xFF2196F3),
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          'assets/images/logo bnb.png',
                          height: 100,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // VTALK title
                      Text(
                        'VTALK',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w200,
                          letterSpacing: 10,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      Text(
                        'SECURE • SIMPLE • SEAMLESS',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom attribution
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'POWERED BY',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    'assets/images/hai_3_dark.png',
                    height: 18,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PRINCIPLES',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
