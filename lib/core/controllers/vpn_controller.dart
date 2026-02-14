import 'package:flutter/foundation.dart';
import 'package:vtalk_app/core/services/vpn/vpn_service.dart';
import 'package:vtalk_app/data/models/server_model.dart';

/// VPN UI state – HAI3 core controller.
/// Tracks connection, current server, split tunneling; notifies for instant UI updates.
class VPNController extends ChangeNotifier {
  VPNController({VPNService? service}) : _service = service ?? VPNService();

  final VPNService _service;
  bool _isConnecting = false;

  bool get isConnected => _service.isConnected;
  bool get isConnecting => _isConnecting;
  ServerModel? get currentServer => _service.currentServer;
  bool get isSplitTunnelingEnabled => _service.isSplitTunnelingEnabled;
  List<String> get splitApps => _service.splitApps;
  List<String> get splitDomains => _service.splitDomains;

  /// Toggle VPN on/off.
  Future<void> toggleVpn() async {
    if (_isConnecting) return;
    _isConnecting = true;
    notifyListeners();
    try {
      await _service.toggleVpn();
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  /// Set split tunneling (Amnesia-style).
  Future<void> setSplitTunneling({
    required List<String> apps,
    required List<String> domains,
    required bool enabled,
  }) async {
    await _service.setSplitTunneling(
      apps: apps,
      domains: domains,
      enabled: enabled,
    );
    notifyListeners();
  }

  /// Select server/location.
  Future<void> selectServer(ServerModel server) async {
    await _service.selectServer(server);
    notifyListeners();
  }
}
