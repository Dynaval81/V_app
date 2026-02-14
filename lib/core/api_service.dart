import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🚨 Провайдер для Dio (HTTP клиент)
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  
  // 🚨 Базовая конфигурация
  dio.options = BaseOptions(
    baseUrl: 'https://hypermax.duckdns.org/api/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );
  
  // 🚨 Интерцептор для логирования
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    requestHeader: true,
    responseHeader: false,
    logPrint: (object) {
      print('🌐 API: $object');
    },
  ));
  
  // 🚨 Интерцептор для токена
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // 🚨 Здесь можно добавить токен из secure storage
      // final token = await _storage.read(key: 'auth_token');
      // if (token != null) {
      //   options.headers['Authorization'] = 'Bearer $token';
      // }
      handler.next(options);
    },
    onError: (error, handler) {
      print('❌ API Error: ${error.message}');
      print('❌ Response: ${error.response?.data}');
      handler.next(error);
    },
  ));
  
  return dio;
});

// 🚨 API сервис
class ApiService {
  final Dio _dio;
  
  ApiService(this._dio);
  
  // 🚨 Провайдер для API сервиса
  static final apiServiceProvider = Provider<ApiService>((ref) {
    return ApiService(ref.read(dioProvider));
  });
  
  // 🚨 Методы для работы с пользователями
  Future<Map<String, dynamic>> getUserData() async {
    try {
      final response = await _dio.get('/user/profile');
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  Future<Map<String, dynamic>> updateUserData(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.put('/user/profile', data: userData);
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // 🚨 Методы для работы с чатами
  Future<Map<String, dynamic>> getChats() async {
    try {
      final response = await _dio.get('/rooms');
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  Future<Map<String, dynamic>> createChat(String targetUserId) async {
    try {
      final response = await _dio.post('/rooms', data: {
        'targetUserId': targetUserId,
      });
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  Future<Map<String, dynamic>> getChatMessages(String chatId) async {
    try {
      final response = await _dio.get('/rooms/$chatId/messages');
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  Future<Map<String, dynamic>> sendMessage(String chatId, String message) async {
    try {
      final response = await _dio.post('/rooms/$chatId/messages', data: {
        'text': message,
        'type': 'text',
      });
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // 🚨 Методы для работы с контактами
  Future<Map<String, dynamic>> getContacts() async {
    try {
      final response = await _dio.get('/contacts');
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  Future<Map<String, dynamic>> searchContacts(String query) async {
    try {
      final response = await _dio.get('/contacts/search', queryParameters: {
        'q': query,
      });
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // 🚨 Методы для работы с VPN
  Future<Map<String, dynamic>> getVpnServers() async {
    try {
      final response = await _dio.get('/vpn/servers');
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  Future<Map<String, dynamic>> connectVpn(String serverId) async {
    try {
      final response = await _dio.post('/vpn/connect', data: {
        'serverId': serverId,
      });
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  Future<Map<String, dynamic>> disconnectVpn() async {
    try {
      final response = await _dio.post('/vpn/disconnect');
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // 🚨 Методы для работы с AI
  Future<Map<String, dynamic>> sendAiMessage(String message) async {
    try {
      final response = await _dio.post('/ai/chat', data: {
        'message': message,
      });
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // 🚨 Методы для аутентификации
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  Future<Map<String, dynamic>> register(String email, String password, String username) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'username': username,
      });
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _dio.post('/auth/logout');
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // 🚨 Методы для работы с файлами
  Future<Map<String, dynamic>> uploadFile(String filePath, String fileType) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'type': fileType,
      });
      
      final response = await _dio.post('/files/upload', data: formData);
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // 🚨 Методы для работы с настройками
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await _dio.get('/settings');
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> settings) async {
    try {
      final response = await _dio.put('/settings', data: settings);
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
