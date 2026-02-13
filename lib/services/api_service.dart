import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String _baseUrl = 'https://hypermax.duckdns.org/api/v1'; // 🎯 НОВЫЙ ДОМЕН БЕЗ СЛЭША
  static const String _tokenKey = 'auth_token';
  static const Duration _timeout = Duration(seconds: 30); // ⭐ ТАЙМАУТ 30 СЕКУНД
  
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Регистрация пользователя
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? username,  // ⭐ Делаем опциональным
    String region = 'RU',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'username': username,  // Отправляем null если пусто
          // ⭐ Region убираем - бэкенд сам ставит
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        // Сохраняем токен
        await _secureStorage.write(key: _tokenKey, value: data['token']);
        return {
          'success': true,
          'user': data['user'],
          'token': data['token'],
        };
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        // ⭐ MATRIX ОШИБКИ - ПРОКИДЫВАЕМ ТЕКСТ ИСКЛЮЧЕНИЯ
        final matrixError = errorData['error'] ?? errorData['message'] ?? 'Registration failed';
        return {
          'success': false,
          'error': matrixError,
        };
      } else {
        // ⭐ ДРУГИЕ ОШИБКИ - ТАКЖЕ ПРОКИДЫВАЕМ ТЕКСТ
        final otherError = data['error'] ?? data['message'] ?? 'Registration failed';
        return {
          'success': false,
          'error': otherError,
        };
      }
    } catch (e) {
      // ⭐ MATRIX ОШИБКИ - ПРОКИДЫВАЕМ ТЕКСТ ИСКЛЮЧЕНИЯ
      String errorMessage = 'Registration failed';
      
      try {
        // Если это Exception с текстом ошибки - прокидываем его
        if (e.toString().contains('Exception:')) {
          final errorString = e.toString().split('Exception: ')[1];
          errorMessage = errorString.replaceAll(RegExp(r'[{}"]'), '').trim();
        } else {
          // Если это другая ошибка - пробуем распарсить как JSON
          final errorString = e.toString().replaceAll('Exception: ', '');
          errorMessage = errorString.replaceAll(RegExp(r'[{}"]'), '').trim();
        }
      } catch (_) {
        errorMessage = 'Network error: ${e.toString()}';
      }
      
      return {
        'success': false,
        'error': errorMessage,
      };
    }
  }

  // Вход пользователя
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'identifier': email,
          'password': password,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      
      print('🔍 Login Server Response: ${response.body}'); // 🎯 DEBUG PRINT
      print('🔍 Login Status Code: ${response.statusCode}'); // 🎯 DEBUG PRINT
      
      if (response.statusCode == 200) {
        // Сохраняем токен
        await _secureStorage.write(key: _tokenKey, value: data['token']);
        return {
          'success': true,
          'user': data['user'],
          'token': data['token'],
          'isFirstLogin': data['user']['isFirstLogin'] ?? false,
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'error': data['error'] ?? 'Email not verified',
          'isEmailNotVerified': true,
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      // ⭐ КРИТИЧНО - ПРАВИЛЬНЫЙ ПАРСИНГ ОШИБОК
      String errorMessage = 'Network error';
      
      try {
        if (e.toString().contains('Exception:')) {
          final errorString = e.toString().split('Exception: ')[1];
          errorMessage = errorString.replaceAll(RegExp(r'[{}"]'), '').trim();
        }
      } catch (_) {
        errorMessage = 'Network error: ${e.toString()}';
      }
      
      return {
        'success': false,
        'error': errorMessage,
      };
    }
  }

  // Получение данных пользователя
  Future<Map<String, dynamic>> getUser() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': data['user'],
        };
      } else {
        // Токен протух, удаляем его
        await _secureStorage.delete(key: _tokenKey);
        return {
          'success': false,
          'error': 'Token expired',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Проверка наличия токена
  Future<bool> hasToken() async {
    final token = await _secureStorage.read(key: _tokenKey);
    return token != null;
  }

  // ⭐ СМЕНА ИМЕНИ ПОЛЬЗОВАТЕЛЯ
  Future<Map<String, dynamic>> changeUsername(String newName) async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }
      
      final response = await http.put(
        Uri.parse('$_baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'username': newName,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'username': data['username'],
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'error': data['message'] ?? 'Это имя зарезервировано системой. Пожалуйста, выберите другое',
        };
      } else if (response.statusCode == 429) {
        return {
          'success': false,
          'error': data['message'] ?? 'Превышен лимит попыток смены имени',
          'nextChangeDate': data['nextChangeDate'], // ⭐ ДАТА СЛЕДУЮЩЕЙ ВОЗМОЖНОСТИ
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Ошибка смены имени',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // ⭐ ПОЛУЧЕНИЕ ДАННЫХ ПОЛЬЗОВАТЕЛЯ
  Future<Map<String, dynamic>> getUserData() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      
      print('🔍 getUserData Server Response: ${response.body}'); // 🎯 DEBUG PRINT
      print('🔍 getUserData Status Code: ${response.statusCode}'); // 🎯 DEBUG PRINT
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to get user data',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // ⭐ ПРОВЕРКА СТАТУСА ВЕРИФИКАЦИИ
  Future<Map<String, dynamic>> checkVerificationStatus(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/check-verification'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email}),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'verified': data['verified'] ?? false,
          'message': data['message'] ?? 'Verification checked',
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Verification check failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // ⭐ АКТИВАЦИЯ PREMIUM
  Future<Map<String, dynamic>> activatePremium(String code) async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/premium/activate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'code': code}),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Premium activated successfully',
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Activation failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Восстановление доступа
  Future<void> recoverAccess(String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/recovery'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode != 200) throw Exception('Recovery failed');
  }

  // Выход
  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
  }
}
