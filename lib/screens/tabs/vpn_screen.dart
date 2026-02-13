import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../utils/glass_kit.dart';
import '../../theme_provider.dart';
import '../../constants/app_constants.dart';
import '../../widgets/vtalk_header.dart';
import '../../widgets/grace_period_banner.dart';
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

  // 🎯 ВЫБОР ЛОКАЦИИ
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
              ...['Frankfurt, Germany', 'Amsterdam, Netherlands', 'London, UK', 'Paris, France'].map((location) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => selectedLocation = location);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selectedLocation == location ? Colors.blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(location),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
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
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              const Text(
                'VPN доступ заблокирован',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Активируйте Premium для разблокировки',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVpnInterface(bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: GlassKit.mainBackground(isDark),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            VtalkHeader(
              title: 'PN', 
              showScrollAnimation: false,
              scrollController: null, 
              logoAsset: 'assets/images/app_logo_mercury.png',
              logoHeight: 54, 
              actions: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage("${AppConstants.defaultAvatarUrl}?u=me"),
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Кнопка подключения
                  GestureDetector(
                    onTap: isConnecting ? null : toggleConnection,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                          color: isConnecting 
                              ? Colors.orange 
                              : isConnected 
                                  ? Colors.green 
                                  : Colors.red,
                          width: 4,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Внешний круг
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: isConnecting
                                    ? [Colors.orange.withOpacity(0.3), Colors.orange.withOpacity(0.1)]
                                    : isConnected
                                        ? [Colors.green.withOpacity(0.3), Colors.green.withOpacity(0.1)]
                                        : [Colors.red.withOpacity(0.3), Colors.red.withOpacity(0.1)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          // Внутренний круг
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: isConnecting
                                    ? [Colors.orange.withOpacity(0.5), Colors.orange.withOpacity(0.2)]
                                    : isConnected
                                        ? [Colors.green.withOpacity(0.5), Colors.green.withOpacity(0.2)]
                                        : [Colors.red.withOpacity(0.5), Colors.red.withOpacity(0.2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          // Иконка состояния
                          Icon(
                            isConnecting 
                                ? Icons.sync 
                                : isConnected 
                                    ? Icons.check_circle 
                                    : Icons.cancel,
                            size: 40,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Статус подключения
                  Text(
                    isConnecting 
                        ? 'Подключение...' 
                        : isConnected 
                            ? 'Подключено' 
                            : 'Отключено',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isConnecting 
                          ? Colors.orange 
                          : isConnected 
                              ? Colors.green 
                              : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Время активности
                  if (isConnected)
                    Text(
                      'Активно: ${_formatDuration(_secondsActive)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),

                  const SizedBox(height: 40),

                  // 🎯 УПРОЩЕННЫЕ НАСТРОЙКИ VPN
                  _glassTile(Icons.vpn_lock, "Status", isConnected ? "Connected" : "Disconnected", null),
                  _glassTile(Icons.public, "Location", selectedLocation, () => _showLocationPicker()),
                  _glassTile(Icons.security, "Protocol", "OpenVPN (Hardcoded)", null),
                  _glassTile(Icons.speed, "Encryption", "AES-256 (Hardcoded)", null),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String l, String v) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Text(l, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)), 
            Text(v, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold))
          ]
        );
      },
    );
  }
  
  Widget _glassTile(IconData i, String t, String v, VoidCallback? onTap) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: GlassKit.liquidGlass(
            child: ListTile(
              leading: Icon(i, color: Colors.blue), 
              title: Text(t, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12)), 
              subtitle: Text(v, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
              trailing: onTap != null ? Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white38 : Colors.black38) : null,
              onTap: onTap,
            )
          ),
        );
      },
    );
  }
  
  String _formatTime(int s) => Duration(seconds: s).toString().split('.').first.padLeft(8, "0");

  Widget _modeOption(String mode) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return ListTile(
          title: Text(mode, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          trailing: mode == "Stealth" ? Icon(Icons.check, color: Colors.blue) : null, // 🎯 HARDCODED
          onTap: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }
}