import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../dashboard_screen.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  final String nickname;
  final String vtalkNumber;

  RegistrationSuccessScreen({
    required this.nickname,
    required this.vtalkNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 80,
              ),
              
              SizedBox(height: 30),
              
              Text(
                'Registration Success!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              SizedBox(height: 40),
              
              Text(
                'Your Vtalk ID:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              
              SizedBox(height: 10),
              
              Text(
                '@$nickname',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              
              SizedBox(height: 30),
              
              // ⭐ ИСПРАВЛЕНО: VT- как неактивный префикс
              Column(
                children: [
                  Text(
                    'Your Vtalk Number:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '(tap to copy)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white38,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 10),
              
              // ⭐ ИСПРАВЛЕНО: При клике копируются только цифры
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: vtalkNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Number copied: $vtalkNumber'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFF252541),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ⭐ VT- неактивный (серый)
                      Text(
                        'VT-',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white38,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      // ⭐ Только цифры зелёные (это и копируется)
                      Text(
                        vtalkNumber,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.copy,
                        color: Colors.green,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 40),
              
              Text(
                'Remember this number!\nYou\'ll need it to login',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              
              SizedBox(height: 40),
              
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}