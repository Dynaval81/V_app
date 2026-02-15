import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/constants/app_constants.dart';
import 'package:vtalk_app/core/controllers/auth_controller.dart';
import 'package:vtalk_app/core/controllers/chat_controller.dart';
import 'package:vtalk_app/core/controllers/tab_visibility_controller.dart';
import 'package:vtalk_app/presentation/screens/auth/login_screen.dart';
import 'package:vtalk_app/presentation/screens/chat/chat_room_screen.dart';
import 'package:vtalk_app/presentation/screens/settings_screen.dart';
import 'package:vtalk_app/screens/splash_screen.dart';
import 'package:vtalk_app/presentation/widgets/airy_button.dart';
import 'package:vtalk_app/presentation/widgets/organisms/main_nav_shell.dart';
import 'package:vtalk_app/data/models/chat_room.dart';
import 'package:vtalk_app/theme_provider.dart';
import 'package:vtalk_app/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

/// 🚀 V-Talk Beta - HAI3 Architecture
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final initialLocation = AppRoutes.splash;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ChatController()),
        ChangeNotifierProvider(create: (_) => TabVisibilityController()..load()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initializeTheme()),
      ],
      child: VTalkApp(initialLocation: initialLocation),
    ),
  );
}

class VTalkApp extends StatelessWidget {
  final String initialLocation;

  const VTalkApp({super.key, required this.initialLocation});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _goRouter(initialLocation),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }

  GoRouter _goRouter(String initialLocation) {
    return GoRouter(
      initialLocation: initialLocation,
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
  }
}

class _ErrorScreen extends StatelessWidget {
  final Exception? error;

  const _ErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Error',
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
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
