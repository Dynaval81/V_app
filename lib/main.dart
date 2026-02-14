import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme.dart';
import 'core/constants/app_constants.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/widgets/airy_button.dart';

/// 🚀 V-Talk Beta - HAI3 Architecture
/// Clean architecture with strict layer separation
void main() {
  runApp(
    const ProviderScope(
      child: VTalkApp(),
    ),
  );
}

class VTalkApp extends ConsumerWidget {
  const VTalkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // 🎨 HAI3 Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // 🌑 Dark theme by default (HAI3)
      
      // 🧭 GoRouter Configuration
      routerConfig: router,
      
      // 📱 Global text scaling disabled (HAI3 consistency)
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
          ),
          child: child!,
        );
      },
    );
  }
}

/// 🧭 HAI3 Router Configuration
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    
    routes: [
      // 🎯 Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      
      // 🔐 Authentication Screen
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      
      // 🏠 Main App (Placeholder - will be implemented)
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const _ComingSoonScreen(
          title: 'Home',
          message: 'Main dashboard coming soon...',
        ),
      ),
      
      // 💬 Chats (Placeholder)
      GoRoute(
        path: AppRoutes.chats,
        builder: (context, state) => const _ComingSoonScreen(
          title: 'Chats',
          message: 'Chat interface coming soon...',
        ),
      ),
      
      // 🤖 AI Assistant (Placeholder)
      GoRoute(
        path: AppRoutes.ai,
        builder: (context, state) => const _ComingSoonScreen(
          title: 'AI Assistant',
          message: 'AI features coming soon...',
        ),
      ),
      
      // 🔒 VPN (Placeholder)
      GoRoute(
        path: AppRoutes.vpn,
        builder: (context, state) => const _ComingSoonScreen(
          title: 'VPN',
          message: 'VPN features coming soon...',
        ),
      ),
      
      // 👤 Profile (Placeholder)
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const _ComingSoonScreen(
          title: 'Profile',
          message: 'Profile management coming soon...',
        ),
      ),
      
      // ⚙️ Settings (Placeholder)
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const _ComingSoonScreen(
          title: 'Settings',
          message: 'Settings interface coming soon...',
        ),
      ),
    ],
    
    // 🚨 Error Handling
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),
  );
});

/// 🎯 Placeholder Screen for Coming Soon Features
class _ComingSoonScreen extends ConsumerWidget {
  final String title;
  final String message;
  
  const _ComingSoonScreen({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🎯 Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  boxShadow: [AppShadows.md],
                ),
                child: const Icon(
                  Icons.construction,
                  color: AppColors.onPrimary,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // 📝 Title
              Text(
                title,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // 📝 Message
              Text(
                message,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // 🔙 Back button
              AiryButton(
                text: 'Back to Auth',
                onPressed: () {
                  context.go(AppRoutes.auth);
                },
                icon: const Icon(Icons.arrow_back, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🚨 Error Screen
class _ErrorScreen extends ConsumerWidget {
  final Object? error;
  
  const _ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🚨 Error Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // 📝 Error Title
              Text(
                'Something went wrong',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // 📝 Error Message
              Text(
                error?.toString() ?? 'Unknown error occurred',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // 🔄 Retry button
              AiryButton(
                text: 'Go to Auth',
                onPressed: () {
                  context.go(AppRoutes.auth);
                },
                icon: const Icon(Icons.refresh, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
