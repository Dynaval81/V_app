import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/constants/app_constants.dart';

/// 🎨 HAI3 Splash Screen with animated logo
/// Minimalist design with smooth transitions
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // 🎬 Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 🌟 Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // 📏 Scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // 🚀 Start animation
    _animationController.forward();

    // 🔄 Navigate to auth after delay
    _navigateToAuth();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToAuth() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        // TODO: Navigate to auth screen using GoRouter
        // context.go('/auth');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000000),
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🎯 Logo with HAI3 styling
                    _buildLogo(),
                    SizedBox(height: AppSpacing.buttonPadding),
                    // 📝 App name with HAI3 typography
                    _buildAppName(),
                    SizedBox(height: AppSpacing.buttonPadding * 3),
                    // 🔄 Loading indicator with HAI3 colors
                    _buildLoadingIndicator(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build animated logo
  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
              colors: [Color(0xFF00A3FF), Color(0xFF0066FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(AppBorderRadius.button),
        boxShadow: [
          AppShadows.md,
        ],
      ),
      child: const Icon(
        Icons.chat_bubble_outline,
        color: Color(0xFFFFFFFF),
        size: 40,
      ),
    );
  }

  /// 📝 Build app name with HAI3 typography
  Widget _buildAppName() {
    return Text(
      AppConstants.appName,
      style: AppTextStyles.h3.copyWith(
        color: Color(0xFF121212),
        fontWeight: FontWeight.w800,
        letterSpacing: 2.0,
      ),
    );
  }

  /// 🔄 Build loading indicator with HAI3 styling
  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A3FF)),
        backgroundColor: Color(0xFF121212).withOpacity(0.2),
      ),
    );
  }
}
