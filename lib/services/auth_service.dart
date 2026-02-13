import 'dart:async';
import 'dart:math';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  
  // Имитация базы данных пользователей
  final List<Map<String, String>> _mockUsers = [];

  // Регистрация пользователя
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    // 1. Имитируем сетевую задержку
    await Future.delayed(const Duration(seconds: 2));

    // 2. Генерируем VT-ID с префиксом VT- и 5 знаками
    String vtId = "VT-${Random().nextInt(90000) + 10000}";

    // 3. Сохраняем "пользователя" (пока в память)
    _mockUsers.add({
      'username': username,
      'email': email,
      'vtId': vtId,
    });

    return {
      'success': true,
      'vtId': vtId,
      'message': 'Welcome to the network, $username'
    };
  }

  // Вход пользователя
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    // 1. Имитируем сетевую задержку
    await Future.delayed(const Duration(seconds: 2));

    // 2. Ищем пользователя в "базе"
    var user = _mockUsers.firstWhere(
      (user) => user['email'] == email,
      orElse: () => {},
    );

    if (user.isEmpty) {
      return {
        'success': false,
        'error': 'User not found'
      };
    }

    return {
      'success': true,
      'vtId': user['vtId'],
      'message': 'Welcome back!'
    };
  }

  // Валидация email или VT-ID
  bool isValidEmail(String email) {
    // ⭐ ПОДДЕРЖКА VT-ID (5 и 6 значных)
    if (RegExp(r'^VT-\d{5,6}$', caseSensitive: false).hasMatch(email)) {
      return true;
    }
    // Стандартная валидация email
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Валидация пароля
  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // ⭐ ПОЛУЧЕНИЕ ДАННЫХ ПОЛЬЗОВАТЕЛЯ (getMe)
  Future<Map<String, dynamic>> getMe() async {
    try {
      final result = await _apiService.getUserData();
      return result;
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to get user data: ${e.toString()}',
      };
    }
  }
}
