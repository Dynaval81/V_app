import 'package:flutter/material.dart';
import 'dart:async';

class VPNScreen extends StatefulWidget {
  @override
  _VPNScreenState createState() => _VPNScreenState();
}

class _VPNScreenState extends State<VPNScreen> {
  bool isConnected = false;
  bool isConnecting = false;
  String selectedMode = 'All Traffic';
  
  // Статистика
  Timer? _timer;
  int _secondsActive = 0;
  String _currentIp = "192.168.1.1"; // Заглушка

  void toggleConnection() async {
    if (isConnected) {
      // Логика отключения
      _timer?.cancel();
      setState(() {
        isConnected = false;
        isConnecting = false;
        _secondsActive = 0;
      });
    } else {
      // Логика подключения
      setState(() {
        isConnecting = true;
      });

      // Имитируем задержку сети 2 секунды
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        isConnecting = false;
        isConnected = true;
        _startTimer();
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _secondsActive++;
      });
    });
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secondsStr = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$secondsStr";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Заголовок
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'VTALK VPN',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),

            Spacer(),

            // Центральная кнопка (Amnezia Style)
            GestureDetector(
              onTap: isConnecting ? null : toggleConnection,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Внешнее свечение
                  AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isConnecting 
                              ? Colors.orange.withOpacity(0.2) 
                              : (isConnected ? Colors.green.withOpacity(0.2) : Colors.blue.withOpacity(0.2)),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  // Основной круг кнопки
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).cardColor,
                      border: Border.all(
                        color: isConnecting 
                            ? Colors.orange 
                            : (isConnected ? Colors.green : Colors.blue),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: isConnecting
                          ? CircularProgressIndicator(color: Colors.orange)
                          : Icon(
                              Icons.power_settings_new,
                              size: 70,
                              color: isConnected ? Colors.green : Colors.blue,
                            ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Статус подключения
            Text(
              isConnecting ? 'ESTABLISHING...' : (isConnected ? 'SECURED' : 'PROTECTION OFF'),
              style: TextStyle(
                color: isConnecting 
                    ? Colors.orange 
                    : (isConnected ? Colors.green : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),

            SizedBox(height: 30),

            // Панель статистики (IP, Uptime, Protocol)
            AnimatedCrossFade(
              firstChild: SizedBox(height: 120), // Пустое место, когда выключено
              secondChild: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    _buildStatRow("Public IP", isConnecting ? "..." : "45.134.144.10"),
                    Divider(color: Theme.of(context).dividerColor.withOpacity(0.3)),
                    _buildStatRow("Uptime", _formatDuration(_secondsActive)),
                    Divider(color: Theme.of(context).dividerColor.withOpacity(0.3)),
                    _buildStatRow("Protocol", "OpenVPN / UDP"),
                  ],
                ),
              ),
              crossFadeState: (isConnected || isConnecting) 
                  ? CrossFadeState.showSecond 
                  : CrossFadeState.showFirst,
              duration: Duration(milliseconds: 400),
            ),

            Spacer(),

            // Выбор режима и сервера
            _buildActionTile(
              icon: Icons.alt_route,
              title: "Tunneling Mode",
              value: selectedMode,
              onTap: () => _showModePicker(),
            ),
            _buildActionTile(
              icon: Icons.location_on,
              title: "Server Location",
              value: "Germany, Frankfurt",
              onTap: () {
                // В будущем: список серверов
              },
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Виджет для строки статистики
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 13)),
          Text(value, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // Виджет для плиток выбора (режим/сервер)
  Widget _buildActionTile({required IconData icon, required String title, required String value, required VoidCallback onTap}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 12)),
        subtitle: Text(value, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).iconTheme.color?.withOpacity(0.4)),
      ),
    );
  }

  // Модалка выбора режима
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
              _modeOption('All Traffic'),
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