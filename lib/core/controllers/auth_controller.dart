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

  // ── Session restore ───────────────────────────────────────────────

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
        debugPrint('[AUTH] restored: ${user.username}, vpn=${user.hasVpnAccess}');
        _setAuthenticated(user);
      } else {
        debugPrint('[AUTH] restore failed: ${result['error']}');
        _setUnauthenticated();
      }
    } catch (e, stack) {
      debugPrint('[AUTH] restore ERROR: $e\n$stack');
      _setUnauthenticated();
    } finally {
      _isRestoringSession = false;
      notifyListeners();
    }
  }

  // ── Login ─────────────────────────────────────────────────────────

  Future<AuthResult> loginWithCredentials({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _api.login(email: identifier, password: password);
      debugPrint('[AUTH] login response: $response');

      if (response['success'] == true) {
        // /auth/login возвращает урезанный user — нужен полный профиль
        // Делаем запрос /auth/me чтобы получить username, hasVpnAccess и т.д.
        final fullResult = await _api.getUser();
        debugPrint('[AUTH] full profile: $fullResult');

        if (fullResult['success'] == true && fullResult['user'] != null) {
          final user = User.fromJson(fullResult['user'] as Map<String, dynamic>);
          debugPrint('[AUTH] parsed: ${user.username}, vpn=${user.hasVpnAccess}');
          _setAuthenticated(user);
        } else {
          // Fallback на данные из login если /auth/me не отработал
          final userJson = response['user'];
          if (userJson != null) {
            final user = User.fromJson(userJson as Map<String, dynamic>);
            _setAuthenticated(user);
          }
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

  // ── Logout ────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _api.logout();
    _setUnauthenticated();
  }

  // ── Legacy shim ───────────────────────────────────────────────────
  /// @deprecated
  void login() => _setAuthenticated(_currentUser ?? _placeholderUser());

  // ── Private ───────────────────────────────────────────────────────

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