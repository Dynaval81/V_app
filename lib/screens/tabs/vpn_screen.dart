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
  int _secondsActive = 0; // duration since connected
  Timer? _timer;
  // traffic stats (bytes)
  int _incomingTraffic = 0;
  int _outgoingTraffic = 0;
  bool _splitTunneling = false;
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
        _incomingTraffic = 0;
        _outgoingTraffic = 0;
      });
    } else {
      setState(() => isConnecting = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        isConnecting = false;
        isConnected = true;
        _incomingTraffic = 0;
        _outgoingTraffic = 0;
        _timer = Timer.periodic(const Duration(seconds: 1), (t) {
          setState(() {
            _secondsActive++;
            // simulate traffic growth
            _incomingTraffic += 1024 + (1000 * (_splitTunneling ? 0 : 1));
            _outgoingTraffic += 512 + (500 * (_splitTunneling ? 0 : 1));
          });
        });
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
                logoAsset: 'assets/images/app_logo_classic.png',
                logoHeight: 40,
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

                    // connection duration / status
                    if (isConnected)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Connected for ${_secondsActive}s',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      ),

                    // traffic statistics
                    if (isConnected || isConnecting) 
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text('Incoming', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54))),
                                Flexible(child: Text('$_incomingTraffic KB', style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text('Outgoing', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54))),
                                Flexible(child: Text('$_outgoingTraffic KB', style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                              ],
                            ),
                          ],
                        ),
                      ),

                    // split tunneling toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('Split tunneling', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                          ),
                          Switch(
                            value: _splitTunneling,
                            onChanged: (v) {
                              setState(() {
                                _splitTunneling = v;
                              });
                            },
                          ),
                        ],
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
