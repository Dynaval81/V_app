import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/organisms/main_nav_shell.dart';
import '../../core/controllers/auth_controller.dart';
import 'auth/login_screen.dart';

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
    
    // Initialize attribution animation controller (starts 500ms later)
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
    
    // Start attribution animation after 500ms delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _attributionAnimationController.forward();
      }
    });
    
    // Navigate after 2 seconds
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _attributionAnimationController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() async {
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;
      
      // Check auth status
      final authController = context.read<AuthController>();
      final isLoggedIn = authController.isAuthenticated;
      
      if (isLoggedIn) {
        // Go to Dashboard
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainNavShell(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      } else {
        // Go to Auth/Login Screen
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
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
                          child: Container(
                            width: 240, // Responsive logo size
                            height: 240,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x3300F5FF),
                                  blurRadius: 50,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: ColorFiltered(
                                colorFilter: isDarkMode 
                                    ? ColorFilter.mode(const Color(0xFF00F5FF), BlendMode.srcIn)
                                    : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                                child: Image.asset(
                                  isDarkMode 
                                      ? 'assets/images/logo wnb.png'
                                      : 'assets/images/logo bnb.png',
                                  width: 240,
                                  height: 240,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Bottom attribution
              AnimatedBuilder(
                animation: _attributionAnimationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _attributionFadeAnimation,
                    child: Column(
                      children: [
                        // HAI3 logo with color filter
                        ColorFiltered(
                          colorFilter: isDarkMode 
                              ? ColorFilter.mode(const Color(0xFF00F5FF), BlendMode.srcIn)
                              : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                          child: Image.asset(
                            isDarkMode 
                                ? 'assets/images/hai_3_light.png'
                                : 'assets/images/hai_3_dark.png',
                            width: 60,
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // HAI3 text
                        Text(
                          'POWERED BY HAI3 PRINCIPLES',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 4.0,
                            fontWeight: FontWeight.w300,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
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
