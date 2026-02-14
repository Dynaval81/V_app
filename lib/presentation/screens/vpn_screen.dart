import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/controllers/vpn_controller.dart';
import 'package:vtalk_app/presentation/widgets/organisms/vpn_panel.dart';

/// VPN screen – scaffold with app bar and [VpnPanel] organism.
class VpnScreen extends StatelessWidget {
  const VpnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VPNController(),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'VPN',
            style: TextStyle(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
        body: const VpnPanel(),
      ),
    );
  }
}
