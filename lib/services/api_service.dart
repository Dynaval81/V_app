import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Используем переменную окружения для базового URL
  static const String _baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://57.128.239.33:3000/api/v1',
  );
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
        // 🎯 ПРАВИЛЬНЫЙ ПАРСИНГ ОТВЕТА БЭКЕНДА (КАК В LOGIN)
        final token = data['token'] ?? data['data']?['token'];
        final userData = data['user'] ?? data['data']?['user'];
        
        if (token != null) {
          await _secureStorage.write(key: _tokenKey, value: token);
        }
        
        return {
          'success': true,
          'user': userData,
          'token': token,
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
      final url = Uri.parse('$_baseUrl/auth/login');
      final headers = {'Content-Type': 'application/json'};
      final bodyMap = {'identifier': email, 'password': password};
      final bodyStr = jsonEncode(bodyMap);

      debugPrint('[API] POST $url');
      debugPrint('[API] headers: $headers');
      debugPrint('[API] body: $bodyStr');

      final response = await http.post(
        url,
        headers: headers,
        body: bodyStr,
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // 🎯 ПРАВИЛЬНЫЙ ПАРСИНГ ОТВЕТА БЭКЕНДА
        final token = data['token'] ?? data['data']?['token'];
        final userData = data['user'] ?? data['data']?['user'];
        
        if (token != null) {
          await _secureStorage.write(key: _tokenKey, value: token);
        }
        
        return {
          'success': true,
          'user': userData,
          'token': token,
          'isFirstLogin': userData?['isFirstLogin'] ?? false,
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
    } catch (e, stack) {
      debugPrint('[API] login error: $e');
      debugPrint('[API] login stack: $stack');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
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

      // 🔄 новый путь
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // теперь данные лежат глубже
        final userJson = data['data']?['user'] ?? data['user'];
        return {
          'success': true,
          'user': userJson,
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
        Uri.parse('$_baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final userJson = data['data']?['user'] ?? data['user'];
        return {
          'success': true,
          'user': userJson,
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

  // 🎯 ГЛОБАЛЬНЫЙ ПОИСК ПОЛЬЗОВАТЕЛЕЙ
  Future<Map<String, dynamic>> searchUsers(String query) async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }

      // строим URI безопасно, чтобы избежать проблем с пробелами и спецсимволами
      final uri = Uri.parse('$_baseUrl/users/search').replace(
        queryParameters: {'query': query},
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // поддерживаем обе возможные структуры ответа
        final usersList = data['data']?['users'] ?? data['users'] ?? [];
        return {
          'success': true,
          'users': usersList,
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to search users',
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

  // ⭐ СОЗДАНИЕ ЧАТА
  Future<Map<String, dynamic>> createChat(String userId) async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token == null) return {'success': false, 'error': 'No token'};

      final response = await http.post(
        Uri.parse('$_baseUrl/chats/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'userId': userId}),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'roomId': data['roomId'] ?? data['data']?['roomId'],
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to create chat',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // ⭐ ПОЛУЧЕНИЕ СПИСКА ЧАТОВ
  Future<Map<String, dynamic>> listChats() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token == null) return {'success': false, 'error': 'No token'};

      final response = await http.get(
        Uri.parse('$_baseUrl/chats/list'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'rooms': data['rooms'] ?? data['data']?['rooms'] ?? [],
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to load chats',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // ⭐ ПОЛУЧЕНИЕ VPN СЕРВЕРОВ
  Future<Map<String, dynamic>> getVpnServers({String? purpose}) async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token == null) return {'success': false, 'error': 'No token'};

      final uri = Uri.parse('$_baseUrl/vpn/servers').replace(
        queryParameters: purpose != null ? {'purpose': purpose} : null,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final servers = data['servers'] ?? data['data']?['servers'] ?? [];
        return {'success': true, 'servers': servers};
      } else {
        return {'success': false, 'error': data['message'] ?? 'Failed to load servers'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: \${e.toString()}'};
    }
  }

  // Выход
  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
  }
}