import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vtalk_app/services/api_service.dart';
import 'package:vtalk_app/data/models/user_model.dart';

class AuthResult {
  final bool success;
  final String? error;
  final bool isEmailNotVerified;

  const AuthResult({
    required this.success,
    this.error,
    this.isEmailNotVerified = false,
  });

  factory AuthResult.ok() => const AuthResult(success: true);

  factory AuthResult.fail(String error, {bool isEmailNotVerified = false}) =>
      AuthResult(success: false, error: error, isEmailNotVerified: isEmailNotVerified);
}

class AuthController extends ChangeNotifier {
  final ApiService _api;
  final FlutterSecureStorage _storage;
  final void Function(User user)? onUserLoaded;

  AuthController({
    ApiService? api,
    FlutterSecureStorage? storage,
    this.onUserLoaded,
  })  : _api = api ?? ApiService(),
        _storage = storage ?? const FlutterSecureStorage();

  bool _isAuthenticated = false;
  bool _isRestoringSession = true;
  User? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  bool get isRestoringSession => _isRestoringSession;
  User? get currentUser => _currentUser;

  Future<void> tryRestoreSession() async {
    _isRestoringSession = true;
    notifyListeners();

    try {
      final hasToken = await _api.hasToken();
      debugPrint('[AUTH] hasToken: $hasToken');
      if (!hasToken) {
        _setUnauthenticated();
        return;
      }

      final result = await _api.getUser();
      debugPrint('[AUTH] getUser result: $result');

      if (result['success'] == true && result['user'] != null) {
        final userJson = result['user'] as Map<String, dynamic>;
        debugPrint('[AUTH] userJson: $userJson');
        final user = User.fromJson(userJson);
        debugPrint('[AUTH] parsed user: ${user.username}, vpn=${user.hasVpnAccess}, premium=${user.isPremium}');
        _setAuthenticated(user);
      } else {
        debugPrint('[AUTH] getUser failed or user null: ${result['error']}');
        _setUnauthenticated();
      }
    } catch (e, stack) {
      debugPrint('[AUTH] tryRestoreSession ERROR: $e');
      debugPrint('[AUTH] stack: $stack');
      _setUnauthenticated();
    } finally {
      _isRestoringSession = false;
      notifyListeners();
    }
  }

  Future<AuthResult> loginWithCredentials({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _api.login(email: identifier, password: password);
      debugPrint('[AUTH] login response: $response');

      if (response['success'] == true) {
        final userJson = response['user'];
        if (userJson != null) {
          final user = User.fromJson(userJson as Map<String, dynamic>);
          debugPrint('[AUTH] login user: ${user.username}, vpn=${user.hasVpnAccess}');
          _setAuthenticated(user);
        }
        return AuthResult.ok();
      }

      final isNotVerified = response['isEmailNotVerified'] == true;
      final errorMsg = response['error']?.toString() ?? 'Ошибка входа';
      return AuthResult.fail(errorMsg, isEmailNotVerified: isNotVerified);
    } catch (e) {
      return AuthResult.fail('Сетевая ошибка: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await _api.logout();
    _setUnauthenticated();
  }

  /// @deprecated
  void login() => _setAuthenticated(_currentUser ?? _placeholderUser());

  void _setAuthenticated(User user) {
    _isAuthenticated = true;
    _currentUser = user;
    onUserLoaded?.call(user);
    notifyListeners();
  }

  void _setUnauthenticated() {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  User _placeholderUser() => User(
        id: 'mock',
        username: 'User',
        email: '',
        vtNumber: '',
      );
}