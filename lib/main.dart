import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/constants/app_constants.dart';
import 'package:vtalk_app/core/controllers/auth_controller.dart';
import 'package:vtalk_app/core/controllers/chat_controller.dart';
import 'package:vtalk_app/core/controllers/tab_visibility_controller.dart';
import 'package:vtalk_app/presentation/screens/auth/login_screen.dart';
import 'package:vtalk_app/presentation/screens/chat/chat_room_screen.dart';
import 'package:vtalk_app/presentation/screens/settings_screen.dart';
import 'package:vtalk_app/presentation/screens/splash_screen.dart';
import 'package:vtalk_app/presentation/widgets/airy_button.dart';
import 'package:vtalk_app/presentation/widgets/organisms/main_nav_shell.dart';
import 'package:vtalk_app/data/models/chat_room.dart';

/// 🚀 V-Talk Beta - HAI3 Architecture
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ChatController()),
        ChangeNotifierProvider(create: (_) => TabVisibilityController()..load()),
      ],
      child: const VTalkApp(),
    ),
  );
}

final _goRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.auth,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const MainNavShell(initialIndex: 0),
    ),
    GoRoute(
      path: '${AppRoutes.chat}/:chatId',
      builder: (context, state) {
        final chatId = state.pathParameters['chatId']!;
        return _ChatScreen(chatId: chatId);
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
  errorBuilder: (context, state) => _ErrorScreen(error: state.error),
);

class VTalkApp extends StatelessWidget {
  const VTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A3FF),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A3FF),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      routerConfig: _goRouter,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final Object? error;

  const _ErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.button),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Color(0xFFFF3B30),
                  size: 40,
                ),
              ),
              const SizedBox(height: AppSpacing.buttonPadding),
              Text(
                'Something went wrong',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.inputPadding),
              Text(
                error?.toString() ?? 'Unknown error occurred',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.buttonPadding * 3),
              AiryButton(
                text: 'Go to Auth',
                onPressed: () => context.go(AppRoutes.auth),
                icon: const Icon(Icons.refresh, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatScreen extends StatelessWidget {
  final String chatId;

  const _ChatScreen({required this.chatId});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ChatController>();
    ChatRoom? room;
    try {
      room = controller.chatRooms.firstWhere((r) => r.id == chatId);
    } catch (_) {}
    if (room == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar: AppBar(title: Text('Chat $chatId')),
        body: const Center(child: Text('Chat not found')),
      );
    }
    return ChatRoomScreen(chat: room);
  }
}
