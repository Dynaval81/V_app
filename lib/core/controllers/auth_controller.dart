import 'package:flutter/foundation.dart';

/// HAI3 Core: Auth state for navigation (minimal prototype).
class AuthController extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  void setAuthenticated(bool value) {
    if (_isAuthenticated == value) return;
    _isAuthenticated = value;
    notifyListeners();
  }

  void login() => setAuthenticated(true);
  void logout() => setAuthenticated(false);
}
