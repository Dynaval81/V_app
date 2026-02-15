import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/controllers/vpn_controller.dart';
import 'package:vtalk_app/data/models/server_model.dart';
import 'package:vtalk_app/presentation/atoms/vpn_connect_button.dart';
import 'package:vtalk_app/presentation/molecules/server_picker.dart';
import 'package:vtalk_app/presentation/molecules/split_tunneling_toggle.dart';

/// Default demo servers (NekoBox-style locations). Single list, no duplicates.
List<ServerModel> get defaultVpnServers => const [
  ServerModel(id: 'us', name: 'United States', countryCode: 'US', flagEmoji: '🇺🇸', host: 'us.example.com', port: 443),
  ServerModel(id: 'de', name: 'Germany', countryCode: 'DE', flagEmoji: '🇩🇪', host: 'de.example.com', port: 443),
  ServerModel(id: 'nl', name: 'Netherlands', countryCode: 'NL', flagEmoji: '🇳🇱', host: 'nl.example.com', port: 443),
  ServerModel(id: 'jp', name: 'Japan', countryCode: 'JP', flagEmoji: '🇯🇵', host: 'jp.example.com', port: 443),
  ServerModel(id: 'sg', name: 'Singapore', countryCode: 'SG', flagEmoji: '🇸🇬', host: 'sg.example.com', port: 443),
];

/// HAI3 Organism: VPN panel – connect button, server picker, split tunneling (Airy).
class VpnPanel extends StatelessWidget {
  final List<ServerModel>? servers;

  const VpnPanel({super.key, this.servers});

  @override
  Widget build(BuildContext context) {
    final list = servers ?? defaultVpnServers;
    return Consumer<VPNController>(
      builder: (context, vpn, _) {
        return Container(
          color: AppColors.surface,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                VpnConnectButton(
                  isConnected: vpn.isConnected,
                  isConnecting: vpn.isConnecting,
                  onPressed: () => vpn.toggleVpn(),
                ),
                const SizedBox(height: 24),
                ServerPicker(
                  servers: list,
                  selectedServer: vpn.currentServer ?? list.first,
                  onServerSelected: (s) => vpn.selectServer(s),
                ),
                const SizedBox(height: 16),
                SplitTunnelingToggle(
                  value: vpn.isSplitTunnelingEnabled,
                  onChanged: (enabled) => vpn.setSplitTunneling(
                    apps: vpn.splitApps,
                    domains: vpn.splitDomains,
                    enabled: enabled,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
