import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../presentation/widgets/organisms/main_nav_shell.dart';
import '../presentation/screens/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _attributionAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _attributionFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize main animation controller
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Initialize attribution animation controller (starts 800ms later for premium feel)
    _attributionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Create fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Create scale animation with easeOutCubic
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Create attribution fade animation
    _attributionFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _attributionAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Start main animation
    _mainAnimationController.forward();
    
    // Start attribution animation after 800ms delay for premium feel
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _attributionAnimationController.forward();
      }
    });
    
    // NAVIGATION LOGIC: Use dedicated Timer to guarantee execution
    Timer(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => user == null ? const LoginScreen() : const MainNavShell(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _attributionAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Light background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Main content area
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _mainAnimationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo with Active Blue tint
                              ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  const Color(0xFF2196F3), // Active Blue
                                  BlendMode.srcIn,
                                ),
                                child: Image.asset(
                                  'assets/images/logo_bnb.png',
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 20),
                              // VTALK text
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
                              // Tagline
                              Text(
                                'SECURE • SIMPLE • SEAMLESS',
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 2,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Bottom HAI3 attribution
              AnimatedBuilder(
                animation: _attributionAnimationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _attributionFadeAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        // HAI3 row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'POWERED BY',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
                            Image.asset(
                              'assets/images/hai_3_dark.png',
                              height: 18,
                              fit: BoxFit.contain,
                            ),
                            Text(
                              'PRINCIPLES',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
