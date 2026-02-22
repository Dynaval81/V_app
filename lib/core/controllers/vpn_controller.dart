import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtalk_app/core/services/vpn/vpn_service.dart';
import 'package:vtalk_app/data/models/server_model.dart';

enum VpnConnectionState { disconnected, connecting, connected, disconnecting }

enum VpnRoutingMode { full, vtalkOnly, custom }

/// HAI3 VPN Controller — single source of truth for VPN UI state.
/// Wired to VpnService; ready for flutter_v2ray integration.
class VpnController extends ChangeNotifier {
  VpnController({VpnService? service}) : _service = service ?? VpnService();

  final VpnService _service;

  // ── Connection state ──────────────────────────────────────────────
  VpnConnectionState _connectionState = VpnConnectionState.disconnected;
  VpnConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == VpnConnectionState.connected;
  bool get isConnecting => _connectionState == VpnConnectionState.connecting;

  // ── Server state ──────────────────────────────────────────────────
  List<ServerModel> _servers = [];
  List<ServerModel> get servers => _servers;

  ServerModel? _selectedServer;
  ServerModel? get selectedServer => _selectedServer;

  bool _autoMode = true;
  bool get autoMode => _autoMode;

  bool _isLoadingServers = false;
  bool get isLoadingServers => _isLoadingServers;

  // Ping map: nodeId → ms
  Map<String, int> _pings = {};
  int? pingFor(String nodeId) => _pings[nodeId];

  // ── Routing state ─────────────────────────────────────────────────
  VpnRoutingMode _routingMode = VpnRoutingMode.full;
  VpnRoutingMode get routingMode => _routingMode;

  List<String> _customDomains = [];
  List<String> get customDomains => List.unmodifiable(_customDomains);

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Call once on screen init.
  Future<void> initialize() async {
    await _loadPreferences();
    await loadServers();
  }

  // ── Servers ───────────────────────────────────────────────────────

  Future<void> loadServers() async {
    _isLoadingServers = true;
    notifyListeners();

    try {
      _servers = await _service.loadServers(purpose: 'general');
      // Ping concurrently in background
      _pingServersInBackground();
    } finally {
      _isLoadingServers = false;
      notifyListeners();
    }
  }

  void _pingServersInBackground() {
    _service.pingAll(_servers).then((pings) {
      _pings = pings;
      notifyListeners();
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
      // Auto-mode: pick fastest server
      ServerModel? target = _selectedServer;
      if (_autoMode || target == null) {
        target = await _service.pickFastest(_servers);
      }

      if (target == null) {
        _connectionState = VpnConnectionState.disconnected;
        notifyListeners();
        return;
      }

      // Load VLESS config
      final configured = await _service.loadConfig(target.nodeId);
      final serverWithConfig = configured ?? target;

      await _service.connect(serverWithConfig);
      _selectedServer = serverWithConfig;
      _connectionState = VpnConnectionState.connected;
    } catch (_) {
      _connectionState = VpnConnectionState.disconnected;
    }

    notifyListeners();
  }

  Future<void> _disconnect() async {
    _connectionState = VpnConnectionState.disconnecting;
    notifyListeners();

    try {
      await _service.disconnect();
    } finally {
      _connectionState = VpnConnectionState.disconnected;
      notifyListeners();
    }
  }

  // ── Routing ───────────────────────────────────────────────────────

  void setRoutingMode(VpnRoutingMode mode) {
    _routingMode = mode;
    switch (mode) {
      case VpnRoutingMode.vtalkOnly:
        _service.setVtalkOnly(true);
        break;
      case VpnRoutingMode.custom:
        _service.setCustomDomains(_customDomains);
        break;
      case VpnRoutingMode.full:
        _service.setVtalkOnly(false);
        break;
    }
    _savePreferences();
    notifyListeners();
  }

  void setCustomDomains(List<String> domains) {
    _customDomains = List.from(domains);
    if (_routingMode == VpnRoutingMode.custom) {
      _service.setCustomDomains(_customDomains);
    }
    _savePreferences();
    notifyListeners();
  }

  // ── Persistence ───────────────────────────────────────────────────

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vpn_auto_mode', _autoMode);
    await prefs.setInt('vpn_routing_mode', _routingMode.index);
    await prefs.setStringList('vpn_custom_domains', _customDomains);
    if (_selectedServer != null) {
      await prefs.setString('vpn_selected_node', _selectedServer!.nodeId);
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _autoMode = prefs.getBool('vpn_auto_mode') ?? true;
    final routingIndex = prefs.getInt('vpn_routing_mode') ?? 0;
    _routingMode = VpnRoutingMode.values[routingIndex];
    _customDomains = prefs.getStringList('vpn_custom_domains') ?? [];
  }
}