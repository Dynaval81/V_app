import 'package:flutter/material.dart';
import 'dart:async';
import '../../utils/glass_kit.dart';

class VPNScreen extends StatefulWidget {
  final bool isDark;
  VPNScreen({this.isDark = true});
  
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
    return Scaffold(
      body: Container(
        width: double.infinity,  // Растягиваем на всю ширину
        height: double.infinity, // Растягиваем на всю высоту
        decoration: GlassKit.mainBackground(widget.isDark),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildAppBar("VTALK VPN"),
                SizedBox(height: 40),

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
                          _row("IP Address", isConnecting ? "..." : "45.134.144.10"),
                          Divider(color: widget.isDark ? Colors.white24 : Colors.black26),
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
        ),
      ),
    );
  }

  Widget _buildAppBar(String title) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: widget.isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
          CircleAvatar(radius: 22, backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=vpn")),
        ],
      ),
    );
  }

  Widget _row(String l, String v) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
    children: [
      Text(l, style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black54)), 
      Text(v, style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold))
    ]
  );
  
  Widget _glassTile(IconData i, String t, String v, VoidCallback? onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: GlassKit.liquidGlass(
        child: ListTile(
          leading: Icon(i, color: Colors.blue), 
          title: Text(t, style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black54, fontSize: 12)), 
          subtitle: Text(v, style: TextStyle(color: widget.isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
          trailing: onTap != null ? Icon(Icons.keyboard_arrow_down, color: widget.isDark ? Colors.white38 : Colors.black38) : null,
          onTap: onTap,
        )
      ),
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
    return ListTile(
      title: Text(mode, style: TextStyle(color: widget.isDark ? Colors.white : Colors.black)),
      trailing: selectedMode == mode ? Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        setState(() => selectedMode = mode);
        Navigator.pop(context);
      },
    );
  }
}