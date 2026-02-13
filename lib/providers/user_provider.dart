import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPremium => _user?.isPremium ?? false;

  void setUser(User user) {
    _user = user;
    _error = null;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void activatePremium(String activationCode) {
    if (_user != null) {
      _user = _user!.copyWith(
        isPremium: true,
        activationCode: activationCode,
      );
      notifyListeners();
    }
  }

  // ⭐ СМЕНА ИМЕНИ ПОЛЬЗОВАТЕЛЯ
  Future<void> updateUsername(String newName, BuildContext context) async {
    try {
      final updatedData = await _apiService.changeUsername(newName);
      
      if (updatedData['success']) {
        _user = _user?.copyWith(username: updatedData['username']);
        notifyListeners(); // Мгновенно обновляем ник во всем приложении
      } else {
        showUsernameError(updatedData['error'], updatedData['nextChangeDate'], context);
      }
    } catch (e) {
      showUsernameError('Ошибка сети: ${e.toString()}', null, context);
    }
  }

  // ⭐ ПОКАЗ ОШИБКИ СМЕНЫ ИМЕНИ
  void showUsernameError(String error, String? nextChangeDate, BuildContext context) {
    if (nextChangeDate != null) {
      // ⭐ 429 ОШИБКА - ЛИМИТ ВРЕМЕНИ
      try {
        final nextDate = DateTime.parse(nextChangeDate);
        final now = DateTime.now();
        final difference = nextDate.difference(now);
        final days = difference.inDays;
        
        _showUsernameSpecialError(
          'Вы сможете сменить имя через $days дней (${_formatDate(nextDate)})',
          null,
          context,
        );
      } catch (e) {
        _showUsernameSpecialError('Ошибка парсинга даты', null, context);
      }
    } else {
      // ⭐ 400 ОШИБКА - СТОП-СЛОВА
      _showUsernameSpecialError(
        'Это имя зарезервировано системой. Пожалуйста, выберите другое',
        null,
        context,
      );
    }
  }

  // ⭐ ПОКАЗ СПЕЦИАЛЬНОГО ОКНА ОШИБКИ
  void _showUsernameSpecialError(String error, String? nextChangeDate, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withOpacity(0.9)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                nextChangeDate != null ? Icons.schedule : Icons.block,
                color: Colors.orange,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                error,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white
                      : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Понятно'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ⭐ ФОРМАТИРОВАНИЕ ДАТЫ
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> clearUser() async {
    _user = null;
    _error = null;
    _isLoading = false;
    
    // 🚨 ИСПРАВЛЕНО: Стираем токен при logout
    await _storage.delete(key: 'auth_token');
    
    notifyListeners();
  }

  // ⭐ ОБНОВЛЕНИЕ ДАННЫХ ПОЛЬЗОВАТЕЛЯ
  Future<void> refreshUserData() async {
    try {
      setLoading(true);
      final result = await _apiService.getUserData();
      
      if (result['success']) {
        _user = User.fromJson(result['user']);
        _error = null;
      } else {
        _error = result['error'] ?? 'Failed to refresh user data';
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
    } finally {
      setLoading(false);
    }
  }
}
