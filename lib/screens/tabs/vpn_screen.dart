import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
  int _incomingTraffic = 0;
  int _outgoingTraffic = 0;
  
  // 🚨 НОВОЕ: Split tunneling как в Amnezia
  bool _splitTunneling = false;
  final TextEditingController _sitesController = TextEditingController();
  final List<String> _availableApps = [
    'Browser',
    'Messenger',
    'PaymentApp',
    'Maps',
    'Social Media',
    'Banking App',
    'Email Client',
    'Video Streaming',
  ];
  final Set<String> _selectedApps = {};
  
  // 🚨 НОВОЕ: Серверы с флагами и пингом
  final List<Map<String, dynamic>> _servers = [
    {'name': 'Auto', 'flag': '🌐', 'ping': '45ms'},
    {'name': 'United States', 'flag': '🇺🇸', 'ping': '120ms'},
    {'name': 'Germany', 'flag': '🇩🇪', 'ping': '65ms'},
    {'name': 'Singapore', 'flag': '🇸🇬', 'ping': '180ms'},
    {'name': 'Japan', 'flag': '🇯🇵', 'ping': '150ms'},
    {'name': 'Brazil', 'flag': '🇧🇷', 'ping': '200ms'},
    {'name': 'United Kingdom', 'flag': '🇬🇧', 'ping': '95ms'},
    {'name': 'Netherlands', 'flag': '🇳🇱', 'ping': '75ms'},
  ];
  String _selectedServer = 'Auto';

  // 🚨 НОВОЕ: Функция для цвета пинга
  Color _getPingColor(String ping) {
    final pingValue = int.parse(ping.replaceAll('ms', ''));
    if (pingValue <= 50) return Colors.green;
    if (pingValue <= 100) return Colors.orange;
    return Colors.red;
  }

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
    _sitesController.dispose();
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
                      CupertinoPageRoute(builder: (context) => const AccountSettingsScreen()),
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
                                if (!v) _selectedApps.clear();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_splitTunneling)
                      Column(
                        children: [
                          // 🚨 НОВОЕ: Раздел "Сайты" как в Amnezia
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            child: GlassKit.liquidGlass(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.language, color: Colors.blueAccent, size: 20),
                                        const SizedBox(width: 8),
                                        Text('Сайты', style: TextStyle(
                                          color: isDark ? Colors.white : Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        )),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _sitesController,
                                      decoration: InputDecoration(
                                        hintText: 'example.com, site.org',
                                        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: Colors.blueAccent),
                                        ),
                                      ),
                                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                      maxLines: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // 🚨 НОВОЕ: Раздел "Приложения" как в Amnezia
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            child: GlassKit.liquidGlass(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.apps, color: Colors.greenAccent, size: 20),
                                        const SizedBox(width: 8),
                                        Text('Приложения', style: TextStyle(
                                          color: isDark ? Colors.white : Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        )),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ..._availableApps.map((app) {
                                      final selected = _selectedApps.contains(app);
                                      return CheckboxListTile(
                                        title: Text(app, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                                        value: selected,
                                        onChanged: (v) {
                                          setState(() {
                                            if (v == true)
                                              _selectedApps.add(app);
                                            else
                                              _selectedApps.remove(app);
                                          });
                                        },
                                        activeColor: Colors.blueAccent,
                                        checkColor: Colors.white,
                                        contentPadding: EdgeInsets.zero,
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 20),

                    // 🚨 НОВОЕ: Server selector с флагами и пингом
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GlassKit.liquidGlass(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.dns, color: Colors.orangeAccent, size: 20),
                                  const SizedBox(width: 8),
                                  Text('Серверы', style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  )),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ..._servers.map((server) {
                                final selected = _selectedServer == server['name'];
                                return ListTile(
                                  leading: Text(
                                    server['flag'],
                                    style: TextStyle(fontSize: 24),
                                  ),
                                  title: Text(
                                    server['name'],
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black,
                                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                  trailing: Text(
                                    server['ping'],
                                    style: TextStyle(
                                      color: _getPingColor(server['ping']),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  selected: selected,
                                  selectedTileColor: (isDark ? Colors.white12 : Colors.black12),
                                  onTap: () {
                                    setState(() => _selectedServer = server['name']);
                                  },
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                );
                              }).toList(),
                            ],
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
