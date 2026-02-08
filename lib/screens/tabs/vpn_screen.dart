import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class VPNScreen extends StatefulWidget {
  @override
  _VPNScreenState createState() => _VPNScreenState();
}

class _VPNScreenState extends State<VPNScreen> {
  bool _isConnected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
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
                    ? AppColors.accentGreen.withOpacity(0.2)
                    : AppColors.disabledTextColor.withOpacity(0.2),
                border: Border.all(
                  color: _isConnected ? AppColors.accentGreen : AppColors.disabledTextColor,
                  width: 3,
                ),
              ),
              child: Center(
                child: Icon(
                  _isConnected ? Icons.vpn_key : Icons.vpn_key_off,
                  size: 80,
                  color: _isConnected ? AppColors.accentGreen : AppColors.disabledTextColor,
                ),
              ),
            ),
            
            SizedBox(height: 30),
            
            Text(
              _isConnected ? 'Connected' : 'Disconnected',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            
            SizedBox(height: 10),
            
            Text(
              _isConnected ? 'Your connection is secure' : 'Tap to connect',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.secondaryText,
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
                backgroundColor: _isConnected ? AppColors.accentRed : AppColors.accentGreen,
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
                  color: AppColors.primaryText,
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
                  color: AppColors.cardBackground,
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
            color: AppColors.secondaryText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
      ],
    );
  }
}