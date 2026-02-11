import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../utils/glass_kit.dart';
import '../../theme_provider.dart';
import '../../constants/app_constants.dart';
import '../../widgets/vtalk_header.dart';
import '../account_settings_screen.dart';

class VPNScreen extends StatefulWidget {
  const VPNScreen({super.key});
  
  @override
  _VPNScreenState createState() => _VPNScreenState();
}

class _VPNScreenState extends State<VPNScreen> {
  bool isConnected = false;
  bool isConnecting = false;
  int _secondsActive = 0;
  Timer? _timer;
  String selectedMode = 'All Apps';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: GlassKit.mainBackground(isDark),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              VtalkHeader(
                title: 'VTALK VPN',
                showScrollAnimation: false,
                scrollController: null, // Без анимации скролла
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
                      child: Center(
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: 180, 
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border: Border.all(
                              color: isConnecting 
                                ? Colors.orange 
                                : (isConnected ? Colors.green : Colors.blue), 
                              width: 3
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isConnected ? Colors.green : Colors.blue).withOpacity(0.2), 
                                blurRadius: 30, 
                                spreadRadius: 10
                              )
                            ],
                          ),
                          child: GlassKit.liquidGlass(
                            radius: 90,
                            child: isConnecting 
                              ? Center(child: CircularProgressIndicator(color: Colors.orange)) 
                              : Icon(
                                  Icons.power_settings_new, 
                                  size: 70, 
                                  color: isConnected ? Colors.green : Colors.blue
                                ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 30),
                    
                    // Инфо-панель (появляется при коннекте)
                    if (isConnected || isConnecting)
                      GlassKit.liquidGlass(
                        radius: 15,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _row("IP Address", isConnecting ? "..." : AppConstants.mockVpnIp),
                              Divider(color: isDark ? Colors.white24 : Colors.black26),
                              _row("Uptime", _formatTime(_secondsActive)),
                            ],
                          ),
                        ),
                      ),

                    SizedBox(height: 20),

                    // Настройки туннелирования
                    _glassTile(Icons.alt_route, "Tunneling Mode", selectedMode, () => _showModePicker()),
                    _glassTile(Icons.public, "Location", "Frankfurt, Germany", null),
                    
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
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

  void _showModePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassKit.liquidGlass(
        radius: 30,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _modeOption('All Apps'),
              _modeOption('Specific Apps'),
              _modeOption('Selected Websites'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeOption(String mode) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return ListTile(
          title: Text(mode, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          trailing: selectedMode == mode ? Icon(Icons.check, color: Colors.blue) : null,
          onTap: () {
            setState(() => selectedMode = mode);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}