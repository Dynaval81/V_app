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
  // only server selection remains
  final List<String> _servers = [
    'United States',
    'Germany',
    'Singapore',
    'Japan',
    'Brazil',
  ];
  String _selectedServer = 'United States';

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
                title: 'TALK VPN', // Убираем "V", оставляем "TALK VPN"
                showScrollAnimation: false,
                // Mercury Sphere увеличенная (handled internally now)
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
                    
                    SizedBox(height: 20),

                    // Server selector dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GlassKit.liquidGlass(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedServer,
                              items: _servers.map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s),
                              )).toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _selectedServer = v);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
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

}
