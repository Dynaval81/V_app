import 'package:vtalk_app/data/models/server_model.dart';

/// VPN engine interface – NekoBox/Amnesia-inspired.
/// Stub implementation; real logic via platform channel / sing-box later.
class VPNService {
  bool _isConnected = false;
  ServerModel? _currentServer;
  List<String> _splitApps = [];
  List<String> _splitDomains = [];
  bool _splitTunnelingEnabled = false;

  bool get isConnected => _isConnected;
  ServerModel? get currentServer => _currentServer;
  List<String> get splitApps => List.unmodifiable(_splitApps);
  List<String> get splitDomains => List.unmodifiable(_splitDomains);
  bool get isSplitTunnelingEnabled => _splitTunnelingEnabled;

  /// On/Off toggle. Returns new connection state.
  Future<bool> toggleVpn() async {
    if (_isConnected) {
      await _disconnect();
      return false;
    } else {
      await _connect();
      return true;
    }
  }

  Future<void> _connect() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _isConnected = true;
  }

  Future<void> _disconnect() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _isConnected = false;
  }

  /// Amnesia-style: choose which apps/domains go through VPN.
  Future<void> setSplitTunneling({
    required List<String> apps,
    required List<String> domains,
    required bool enabled,
  }) async {
    _splitApps = List.from(apps);
    _splitDomains = List.from(domains);
    _splitTunnelingEnabled = enabled;
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// Set current server/location.
  Future<void> selectServer(ServerModel server) async {
    _currentServer = server;
    await Future.delayed(const Duration(milliseconds: 50));
  }
}
