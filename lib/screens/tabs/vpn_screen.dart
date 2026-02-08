import 'package:flutter/material.dart';

class VPNScreen extends StatefulWidget {
  @override
  _VPNScreenState createState() => _VPNScreenState();
}

class _VPNScreenState extends State<VPNScreen> {
  bool _isConnected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Color(0xFF252541),
        elevation: 0,
        title: Text('VPN'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // VPN Status Circle
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isConnected
                    ? Colors.green.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                border: Border.all(
                  color: _isConnected ? Colors.green : Colors.grey,
                  width: 3,
                ),
              ),
              child: Center(
                child: Icon(
                  _isConnected ? Icons.vpn_key : Icons.vpn_key_off,
                  size: 80,
                  color: _isConnected ? Colors.green : Colors.grey,
                ),
              ),
            ),
            
            SizedBox(height: 30),
            
            Text(
              _isConnected ? 'Connected' : 'Disconnected',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: 10),
            
            Text(
              _isConnected ? 'Your connection is secure' : 'Tap to connect',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white60,
              ),
            ),
            
            SizedBox(height: 40),
            
            // Connect Button
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isConnected = !_isConnected;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isConnected ? Colors.red : Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                _isConnected ? 'Disconnect' : 'Connect',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            SizedBox(height: 40),
            
            // Server Info
            if (_isConnected)
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Color(0xFF252541),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Server', 'USA East'),
                    SizedBox(height: 8),
                    _buildInfoRow('IP', '192.168.1.1'),
                    SizedBox(height: 8),
                    _buildInfoRow('Uptime', '00:05:32'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white60,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}