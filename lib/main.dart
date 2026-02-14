import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider;
import 'core/constants.dart';
import 'core/constants/app_constants.dart';
import 'core/controllers/chat_controller.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/ai/ai_assistant_screen.dart';
import 'presentation/screens/chats_screen.dart';
import 'presentation/screens/vpn_screen.dart';
import 'presentation/widgets/airy_button.dart';
import 'presentation/widgets/organisms/main_nav_shell.dart';

/// 🚀 V-Talk Beta - HAI3 Architecture
/// Clean architecture with strict layer separation
void main() {
  runApp(
    ProviderScope(
      child: provider.ChangeNotifierProvider(
        create: (_) => ChatController()..loadChats(),
        child: const VTalkApp(),
      ),
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
      
      // 🎨 HAI3 Material 3 Theme Configuration
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF00A3FF),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF00A3FF),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system, // � Adaptive to system (Light/Dark)
      
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
      
      // 💬 Chats
      GoRoute(
        path: AppRoutes.chats,
        builder: (context, state) => const MainNavShell(
          currentIndex: 0,
          child: ChatsScreen(),
        ),
      ),
      
      // 💬 Individual Chat
      GoRoute(
        path: '${AppRoutes.chat}/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          return _ChatScreen(chatId: chatId);
        },
      ),
      
      // 🤖 AI Chat
      GoRoute(
        path: AppRoutes.ai,
        builder: (context, state) => const MainNavShell(
          currentIndex: 1,
          child: AiAssistantScreen(),
        ),
      ),
      
      // 🔒 VPN
      GoRoute(
        path: AppRoutes.vpn,
        builder: (context, state) => const MainNavShell(
          currentIndex: 2,
          child: VpnScreen(),
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
      backgroundColor: Color(0xFF000000),
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
                  borderRadius: BorderRadius.circular(AppBorderRadius.button),
                  boxShadow: [AppShadows.md],
                ),
                child: const Icon(
                  Icons.construction,
                  color: AppColors.onPrimary,
                  size: 40,
                ),
              ),
              
              SizedBox(height: AppSpacing.buttonPadding),
              
              // 📝 Title
              Text(
                title,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              
              SizedBox(height: AppSpacing.inputPadding),
              
              // 📝 Message
              Text(
                message,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: AppSpacing.buttonPadding * 3),
              
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
      backgroundColor: Color(0xFF000000),
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
                  color: Color(0xFFFF3B30).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.button),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Color(0xFFFF3B30),
                  size: 40,
                ),
              ),
              
              SizedBox(height: AppSpacing.buttonPadding),
              
              // 📝 Error Title
              Text(
                'Something went wrong',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              
              SizedBox(height: AppSpacing.inputPadding),
              
              // 📝 Error Message
              Text(
                error?.toString() ?? 'Unknown error occurred',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: AppSpacing.buttonPadding * 3),
              
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

/// 💬 Individual Chat Screen (Placeholder)
class _ChatScreen extends StatelessWidget {
  final String chatId;
  
  const _ChatScreen({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000000),
      appBar: AppBar(
        title: Text('Chat $chatId'),
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF121212),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: Color(0xFF00A3FF),
              size: 80,
            ),
            const SizedBox(height: AppSpacing.buttonPadding),
            Text(
              'Chat Room: $chatId',
              style: AppTextStyles.h3.copyWith(
                color: Color(0xFF121212),
              ),
            ),
            const SizedBox(height: AppSpacing.inputPadding),
            Text(
              'Individual chat screen coming soon...',
              style: AppTextStyles.body.copyWith(
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(height: AppSpacing.buttonPadding),
            AiryButton(
              text: 'Back to Chats',
              onPressed: () {
                context.go(AppRoutes.chats);
              },
              icon: const Icon(Icons.arrow_back, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
