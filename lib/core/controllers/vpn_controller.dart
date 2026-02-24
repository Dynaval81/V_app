import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtalk_app/core/services/vpn/vpn_service.dart';
import 'package:vtalk_app/data/models/server_model.dart';

enum VpnConnectionState { disconnected, connecting, connected, disconnecting }

enum VpnRoutingMode { full, vtalkOnly, apps, custom }

class VpnController extends ChangeNotifier {
  final VPNService _service = VPNService();

  VpnController() {
    _service.initialize(_onServiceStatusChanged);
  }

  void _onServiceStatusChanged(bool connected) {
    debugPrint('[VPN Controller] Status callback: $connected');
    if (connected) {
      _connectionState = VpnConnectionState.connected;
    } else {
      if (_connectionState != VpnConnectionState.disconnecting) {
        _connectionState = VpnConnectionState.disconnected;
      }
    }
    notifyListeners();
  }

  // ── Connection ────────────────────────────────────────────────────
  VpnConnectionState _connectionState = VpnConnectionState.disconnected;
  VpnConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == VpnConnectionState.connected;
  bool get isConnecting => _connectionState == VpnConnectionState.connecting;

  // ── Servers ───────────────────────────────────────────────────────
  List<ServerModel> _servers = [];
  List<ServerModel> get servers => _servers;
  ServerModel? _selectedServer;
  ServerModel? get selectedServer => _selectedServer;
  bool _autoMode = true;
  bool get autoMode => _autoMode;
  bool _isLoadingServers = false;
  bool get isLoadingServers => _isLoadingServers;
  Map<String, int?> _pings = {};
  int? pingFor(String nodeId) => _pings[nodeId];

  // ── Routing ───────────────────────────────────────────────────────
  VpnRoutingMode _routingMode = VpnRoutingMode.full;
  VpnRoutingMode get routingMode => _routingMode;
  List<String> _customDomains = [];
  List<String> get customDomains => List.unmodifiable(_customDomains);
  List<String> _selectedApps = [];
  List<String> get selectedApps => List.unmodifiable(_selectedApps);

  // ── Lifecycle ─────────────────────────────────────────────────────
  Future<void> initialize() async {
    await _loadPreferences();
    await loadServers();
  }

  Future<void> loadServers() async {
    _isLoadingServers = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.loadServers(purpose: 'general'),
        _service.loadServers(purpose: 'reverse'),
      ]);
      _servers = [...results[0], ...results[1]];
      debugPrint('[VPN Controller] Loaded ${_servers.length} servers');
      _pingServersInBackground();
    } catch (e) {
      debugPrint('[VPN Controller] loadServers error: $e');
    } finally {
      _isLoadingServers = false;
      notifyListeners();
    }
  }

  void _pingServersInBackground() {
    _service.pingAll(_servers).then((pings) {
      _pings = pings;
      notifyListeners();
    }).catchError((Object e) {
      debugPrint('[VPN Controller] ping error: $e');
    });
  }

  void selectServer(ServerModel server) {
    _autoMode = false;
    _selectedServer = server;
    _savePreferences();
    notifyListeners();
  }

  void setAutoMode(bool enabled) {
    _autoMode = enabled;
    if (enabled) _selectedServer = null;
    _savePreferences();
    notifyListeners();
  }

  // ── Connect / Disconnect ──────────────────────────────────────────
  Future<void> toggleConnection() async {
    if (_connectionState == VpnConnectionState.connecting ||
        _connectionState == VpnConnectionState.disconnecting) return;
    if (isConnected) {
      await _disconnect();
    } else {
      await _connect();
    }
  }

  Future<void> _connect() async {
    _connectionState = VpnConnectionState.connecting;
    notifyListeners();
    try {
      ServerModel? target = _selectedServer;
      if (_autoMode || target == null) {
        debugPrint('[VPN Controller] Auto: picking fastest...');
        target = await _service.pickFastest(_servers);
      }
      if (target == null) {
        debugPrint('[VPN Controller] No server available');
        _connectionState = VpnConnectionState.disconnected;
        notifyListeners();
        return;
      }
      debugPrint('[VPN Controller] Loading config for ${target.nodeId}...');
      final configured = await _service.loadConfig(target.nodeId);
      final serverWithConfig = configured ?? target;
      debugPrint('[VPN Controller] vlessUri: ${serverWithConfig.vlessUri != null ? "OK" : "MISSING"}');
      await _service.connect(serverWithConfig);
      _selectedServer = serverWithConfig;
      // State set via _onServiceStatusChanged callback
    } catch (e) {
      debugPrint('[VPN Controller] connect error: $e');
      _connectionState = VpnConnectionState.disconnected;
      notifyListeners();
    }
  }

  Future<void> _disconnect() async {
    _connectionState = VpnConnectionState.disconnecting;
    notifyListeners();
    try {
      await _service.disconnect();
    } catch (e) {
      debugPrint('[VPN Controller] disconnect error: $e');
    } finally {
      _connectionState = VpnConnectionState.disconnected;
      notifyListeners();
    }
  }

  // ── Routing ───────────────────────────────────────────────────────
  void setRoutingMode(VpnRoutingMode mode) {
    _routingMode = mode;
    _applyRoutingToService();
    _savePreferences();
    notifyListeners();
  }

  void setCustomDomains(List<String> domains) {
    _customDomains = List.from(domains);
    _applyRoutingToService();
    _savePreferences();
    notifyListeners();
  }

  void setSelectedApps(List<String> packageNames) {
    _selectedApps = List.from(packageNames);
    _applyRoutingToService();
    _savePreferences();
    notifyListeners();
  }

  void _applyRoutingToService() {
    final domains = <String>[];

    switch (_routingMode) {
      case VpnRoutingMode.vtalkOnly:
        // Only VTalk domains go through VPN — everything else direct
        domains.addAll(['vtalk.app', 'hypermax.duckdns.org']);
        _service.setSplitTunneling(
          apps: [],
          domains: domains,
          enabled: true,
        );
        break;
      case VpnRoutingMode.custom:
        _service.setSplitTunneling(
          apps: _selectedApps,
          domains: _customDomains,
          enabled: true,
        );
        break;
      case VpnRoutingMode.apps:
        _service.setSplitTunneling(
          apps: _selectedApps,
          domains: [],
          enabled: _selectedApps.isNotEmpty,
        );
        break;
      case VpnRoutingMode.full:
        _service.setSplitTunneling(
          apps: [],
          domains: [],
          enabled: false,
        );
        break;
    }
  }

  // ── Persistence ───────────────────────────────────────────────────
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('vpn_auto_mode', _autoMode);
      await prefs.setInt('vpn_routing_mode', _routingMode.index);
      await prefs.setStringList('vpn_custom_domains', _customDomains);
      await prefs.setStringList('vpn_selected_apps', _selectedApps);
      if (_selectedServer != null) {
        await prefs.setString('vpn_selected_node', _selectedServer!.nodeId);
      }
    } catch (e) {
      debugPrint('[VPN Controller] savePreferences error: $e');
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _autoMode = prefs.getBool('vpn_auto_mode') ?? true;
      final routingIndex = prefs.getInt('vpn_routing_mode') ?? 0;
      if (routingIndex < VpnRoutingMode.values.length) {
        _routingMode = VpnRoutingMode.values[routingIndex];
      }
      _customDomains = prefs.getStringList('vpn_custom_domains') ?? [];
      _selectedApps = prefs.getStringList('vpn_selected_apps') ?? [];
    } catch (e) {
      debugPrint('[VPN Controller] loadPreferences error: $e');
    }
  }
}