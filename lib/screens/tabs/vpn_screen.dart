import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../utils/glass_kit.dart';
import '../../theme_provider.dart';
import '../../constants/app_constants.dart';
import '../../widgets/vtalk_header.dart';
import '../../widgets/grace_period_banner.dart';
import '../../providers/user_provider.dart';
import '../account_settings_screen.dart';

class VPNScreen extends StatefulWidget {
  final bool isLocked;
  
  const VPNScreen({super.key, this.isLocked = false});
  
  @override
  _VPNScreenState createState() => _VPNScreenState();
}

class _VPNScreenState extends State<VPNScreen> {
  bool isConnected = false;
  bool isConnecting = false;
  int _secondsActive = 0;
  Timer? _timer;
  String selectedLocation = "Frankfurt, Germany"; // 🎯 ТОЛЬКО ВЫБОР ЛОКАЦИИ
  String selectedFlag = "🇩🇪"; // 🎯 ФЛАГ СТРАНЫ
  int pingMs = 25; // 🎯 ПИНГ СЕРВЕРА
  String tunnelMode = "full"; // 🎯 SPLIT TUNNELING: full/selective
  List<String> selectedApps = []; // 🎯 ВЫБРАННЫЕ ПРИЛОЖЕНИЯ
  int trafficIn = 0; // 🎯 ВХОДЯЩИЙ ТРАФИК
  int trafficOut = 0; // 🎯 ИСХОДЯЩИЙ ТРАФИК

  void toggleConnection() async {
    if (isConnected) {
      _timer?.cancel();
      setState(() { 
        isConnected = false; 
        isConnecting = false;
        _secondsActive = 0; 
      });
    } else {
      setState(() => isConnecting = true);
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        isConnecting = false;
        isConnected = true;
        _timer = Timer.periodic(Duration(seconds: 1), (t) => setState(() => _secondsActive++));
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ⭐ ФОРМАТИРОВАНИЕ ДЛИТЕЛЬНОСТИ
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // 🎯 ВЫБОР ЛОКАЦИИ С ФЛАГАМИ И ПИНГОМ
  void _showLocationPicker() {
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
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Server Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...[
                {'location': 'Frankfurt, Germany', 'flag': '🇩🇪', 'ping': 25},
                {'location': 'Amsterdam, Netherlands', 'flag': '🇳🇱', 'ping': 30},
                {'location': 'London, UK', 'flag': '🇬🇧', 'ping': 35},
                {'location': 'Paris, France', 'flag': '🇫🇷', 'ping': 40},
              ].map((server) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLocation = server['location'] as String;
                        selectedFlag = server['flag'] as String;
                        pingMs = server['ping'] as int;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selectedLocation == server['location'] ? Colors.blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(server['flag'] as String, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(server['location'] as String)),
                          Text('${server['ping']}ms', style: TextStyle(color: Colors.grey[600]!, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // 🎯 ВЫБОР РЕЖИМА TUNNELING
  void _showTunnelModePicker() {
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
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Tunneling Mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...[
                {'mode': 'full', 'description': 'All traffic'},
                {'mode': 'selective', 'description': 'Selected apps only'},
              ].map((mode) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => tunnelMode = mode['mode'] as String);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: tunnelMode == (mode['mode'] as String) ? Colors.blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            tunnelMode == (mode['mode'] as String) ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(mode['description']!)),
                        ],
                      ),
                    ),
                  ),
                ),
              ).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // 🎯 ВЫБОР ПРИЛОЖЕНИЙ ДЛЯ SPLIT TUNNELING
  void _showAppSelector() {
    final apps = [
      'WhatsApp', 'Telegram', 'Instagram', 'Facebook', 'Chrome', 'Firefox',
      'YouTube', 'Netflix', 'Spotify', 'Gmail', 'Twitter', 'Discord'
    ];
    
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
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Apps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...apps.map((app) => 
                CheckboxListTile(
                  title: Text(app),
                  value: selectedApps.contains(app),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedApps.add(app);
                      } else {
                        selectedApps.remove(app);
                      }
                    });
                  },
                ),
              ).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockedContent(bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: GlassKit.mainBackground(isDark),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock,
                size: 80,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 24),
              const Text(
                'This feature is available for Premium users',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Upgrade to Premium to unlock VPN functionality',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                width: 200,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Enter promo code',
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    hintStyle: TextStyle(color: Colors.white38),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _activatePremium(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Activate',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🎯 АКТИВАЦИЯ PREMIUM
  void _activatePremium() async {
    // TODO: Реализовать активацию промокода
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Premium activation coming soon!')),
    );
  }

  Widget _glassTile(IconData icon, String title, String value, VoidCallback? onTap) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: isDark ? Colors.white70 : Colors.black54, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right, color: isDark ? Colors.white54 : Colors.black45, size: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: Column(
            children: [
              // ⭐ GRACE PERIOD BANNER
              const GracePeriodBanner(),
              Expanded(
                child: widget.isLocked
                    ? _buildLockedContent(isDark)
                    : _buildVpnInterface(isDark),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildVpnInterface(bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: GlassKit.mainBackground(isDark),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎯 УПРОЩЕННЫЕ НАСТРОЙКИ VPN
              _glassTile(Icons.vpn_lock, "Status", isConnected ? "Connected" : "Disconnected", null),
              _glassTile(Icons.public, "Location", "$selectedFlag $selectedLocation", () => _showLocationPicker()),
              _glassTile(Icons.security, "Protocol", "OpenVPN (Hardcoded)", null),
              _glassTile(Icons.speed, "Encryption", "AES-256 (Hardcoded)", null),
              
              const SizedBox(height: 20),

              // 🎯 SPLIT TUNNELING
              _glassTile(Icons.alt_route, "Tunneling", tunnelMode == "full" ? "All traffic" : "Selected apps", () => _showTunnelModePicker()),
              
              // 🎯 ВЫБОР ПРИЛОЖЕНИЙ (ТОЛЬКО ПРИ SELECTIVE)
              if (tunnelMode == "selective") ...[
                const SizedBox(height: 10),
                _glassTile(Icons.apps, "Selected Apps", "${selectedApps.length} apps", () => _showAppSelector()),
              ],

              const SizedBox(height: 20),

              // 🎯 АКТИВНАЯ СЕССИЯ (ТОЛЬКО ПРИ ПОДКЛЮЧЕНИИ)
              if (isConnected) ...[
                _glassTile(Icons.timer, "Duration", _formatDuration(_secondsActive), null),
                _glassTile(Icons.arrow_downward, "Traffic In", "${trafficIn} MB", null),
                _glassTile(Icons.arrow_upward, "Traffic Out", "${trafficOut} MB", null),
              ],
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
