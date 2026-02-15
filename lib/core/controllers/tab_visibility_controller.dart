import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _keyShowAiTab = 'dashboard_show_ai_tab';
const String _keyShowVpnTab = 'dashboard_show_vpn_tab';

/// Persists and exposes AI/VPN tab visibility for the main nav (SharedPreferences).
class TabVisibilityController extends ChangeNotifier {
  bool _showAiTab = true;
  bool _showVpnTab = true;
  bool _hasChanged = false;

  bool get showAiTab => _showAiTab;
  bool get showVpnTab => _showVpnTab;
  bool get hasChanged => _hasChanged;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _showAiTab = prefs.getBool(_keyShowAiTab) ?? true;
    _showVpnTab = prefs.getBool(_keyShowVpnTab) ?? true;
    notifyListeners();
  }

  Future<void> setShowAiTab(bool value) async {
    if (_showAiTab == value) return;
    _showAiTab = value;
    _hasChanged = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowAiTab, value);
    notifyListeners();
  }

  Future<void> setShowVpnTab(bool value) async {
    if (_showVpnTab == value) return;
    _showVpnTab = value;
    _hasChanged = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowVpnTab, value);
    notifyListeners();
  }

  void resetChangedFlag() {
    _hasChanged = false;
  }
}
