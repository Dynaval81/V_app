import 'package:flutter/material.dart';
import 'dart:async';

class VPNScreen extends StatefulWidget {
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        // Решение проблемы Overflow: SingleChildScrollView
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                'VTALK VPN', 
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color, 
                  fontSize: 20, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 2
                )
              ),
              
              SizedBox(height: 40), // Вместо Spacer используем фиксированные отступы

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
                      color: Theme.of(context).cardColor,
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
              
              SizedBox(height: 30),
              
              // Инфо-панель (появляется при коннекте)
              if (isConnected || isConnecting)
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor, 
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Column(
                    children: [
                      _row("IP Address", isConnecting ? "..." : "45.134.144.10"),
                      Divider(color: Theme.of(context).dividerColor.withOpacity(0.3)),
                      _row("Uptime", _formatTime(_secondsActive)),
                    ],
                  ),
                ),

              SizedBox(height: 20),

              // Настройки туннелирования
              _tile(Icons.alt_route, "Tunneling Mode", selectedMode, () => _showModePicker()),
              _tile(Icons.public, "Location", "Frankfurt, Germany", null),
              
              SizedBox(height: 20), // Чтобы снизу не прижималось к навигации
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String l, String v) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
    children: [
      Text(l, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7))), 
      Text(v, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold))
    ]
  );
  
  Widget _tile(IconData i, String t, String v, VoidCallback? onTap) => Container(
    margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor, 
      borderRadius: BorderRadius.circular(12)
    ),
    child: ListTile(
      leading: Icon(i, color: Colors.blue), 
      title: Text(t, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 12)), 
      subtitle: Text(v, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
      trailing: onTap != null ? Icon(Icons.keyboard_arrow_down, color: Theme.of(context).iconTheme.color?.withOpacity(0.4)) : null,
      onTap: onTap,
    )
  );
  
  String _formatTime(int s) => Duration(seconds: s).toString().split('.').first.padLeft(8, "0");

  void _showModePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _modeOption('All Apps'),
              _modeOption('Specific Apps'),
              _modeOption('Selected Websites'),
            ],
          ),
        );
      },
    );
  }

  Widget _modeOption(String mode) {
    return ListTile(
      title: Text(mode, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
      trailing: selectedMode == mode ? Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        setState(() => selectedMode = mode);
        Navigator.pop(context);
      },
    );
  }
}