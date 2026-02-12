import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import '../providers/user_provider.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  StreamSubscription? _sub;

  // ⭐ ИНИЦИАЛИЗАЦИЯ DEEP LINK
  Future<void> init(BuildContext context) async {
    try {
      // Проверяем ссылку при запуске
      final initialLink = await AppLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink.toString(), context);
      }

      // Слушаем новые ссылки
      _sub = AppLinks.uriLinkStream.listen((Uri? link) {
        if (link != null) {
          _handleDeepLink(link.toString(), context);
        }
      }, onError: (err) {
        // Обработка ошибок
        print('Deep link error: $err');
      });
    } catch (e) {
      print('Deep link initialization error: $e');
    }
  }

  // ⭐ ОБРАБОТКА DEEP LINK
  void _handleDeepLink(String link, BuildContext context) async {
    print('Deep link received: $link');

    // Проверяем нашу схему vtalk://
    if (link.startsWith('vtalk://verified')) {
      // Извлекаем параметры если нужно
      // Например: vtalk://verified?token=abc123
      
      try {
        // Автоматический вход
        final result = await ApiService().login(
          email: '', // Будет получен из ссылки или сохранен
          password: '', // Будет получен из ссылки или сохранен
        );

        if (result['success'] && context.mounted) {
          // Обновляем UserProvider
          final user = result['user'];
          Provider.of<UserProvider>(context, listen: false).setUser(user);
          
          // Переходим на MainScreen
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/main',
            (route) => false,
          );
        }
      } catch (e) {
        print('Auto login error: $e');
        // Показываем ошибку или переходим на экран входа
      }
    }
  }

  // ⭐ ОЧИСТКА РЕСУРСОВ
  void dispose() {
    _sub?.cancel();
  }
}
