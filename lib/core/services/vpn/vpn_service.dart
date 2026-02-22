import 'dart:io';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:vtalk_app/data/models/server_model.dart';
import 'package:vtalk_app/services/api_service.dart';

/// VPN engine — flutter_v2ray integration with VLESS+Reality.
/// Path: lib/core/services/vpn/vpn_service.dart
class VpnService {
  final ApiService _api = ApiService();

  // flutter_v2ray instance
  late final FlutterV2ray _v2ray;
  bool _initialized = false;

  bool _isConnected = false;
  ServerModel? _currentServer;
  List<String> _splitDomains = [];
  bool _vtalkOnlyMode = false;

  bool get isConnected => _isConnected;
  ServerModel? get currentServer => _currentServer;
  List<String> get splitDomains => List.unmodifiable(_splitDomains);
  bool get vtalkOnlyMode => _vtalkOnlyMode;

  // ── Init ──────────────────────────────────────────────────────────

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _v2ray = FlutterV2ray(
      onStatusChanged: (status) {
        _isConnected = status.state == 'CONNECTED';
      },
    );
    await _v2ray.initializeV2Ray();
    _initialized = true;
  }

  // ── Server list ───────────────────────────────────────────────────

  Future<List<ServerModel>> loadServers({String? purpose}) async {
    try {
      final result = await _api.getVpnServers(purpose: purpose);
      if (result['success'] == true) {
        final list = result['servers'] as List<dynamic>;
        return list
            .map((e) => ServerModel.fromJson(e as Map<String, dynamic>))
            .where((s) => s.available)
            .toList();
      }
    } catch (_) {}
    return _fallbackServers();
  }

  Future<ServerModel?> loadConfig(String nodeId) async {
    try {
      final result = await _api.getVpnConfig(nodeId);
      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        return ServerModel.fromJson({
          'id': data['nodeId'] ?? nodeId,
          'nodeId': data['nodeId'] ?? nodeId,
          'location': data['location'] ?? '',
          'countryCode': _countryFromNodeId(nodeId),
          'endpoint': data['endpoint'] ?? '',
          'purpose': 'general',
          'capacity': 1000,
          'currentLoad': 0,
          'loadPercentage': 0,
          'configType': data['configType'] ?? 'vless',
          'isAI': false,
          'available': true,
          'vlessUri': data['vlessUri'],
        });
      }
    } catch (_) {}
    return null;
  }

  // ── Ping ──────────────────────────────────────────────────────────

  Future<int?> pingServer(ServerModel server) async {
    try {
      final stopwatch = Stopwatch()..start();
      final socket = await Socket.connect(
        server.host,
        server.port,
        timeout: const Duration(seconds: 3),
      );
      stopwatch.stop();
      socket.destroy();
      return stopwatch.elapsedMilliseconds;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, int>> pingAll(List<ServerModel> servers) async {
    final results = await Future.wait(
      servers.map((s) async {
        final ms = await pingServer(s);
        return MapEntry(s.nodeId, ms ?? 9999);
      }),
    );
    return Map.fromEntries(results);
  }

  Future<ServerModel?> pickFastest(List<ServerModel> servers) async {
    if (servers.isEmpty) return null;
    final pings = await pingAll(servers);
    servers.sort((a, b) =>
        (pings[a.nodeId] ?? 9999).compareTo(pings[b.nodeId] ?? 9999));
    return servers.first;
  }

  // ── Connect ───────────────────────────────────────────────────────

  Future<void> connect(ServerModel server) async {
    await _ensureInitialized();

    final uri = server.vlessUri;
    if (uri == null || uri.isEmpty) {
      throw Exception('No VLESS URI for node ${server.nodeId}');
    }

    // Parse VLESS URI into V2Ray config
    final v2rayUrl = FlutterV2ray.parseFromURL(uri);

    // Request VPN permission (Android shows system dialog)
    final hasPermission = await _v2ray.requestPermission();
    if (!hasPermission) {
      throw Exception('VPN permission denied');
    }

    // Build bypass list for split tunneling
    final bypassSubnets = _buildBypassList();

    await _v2ray.startV2Ray(
      remark: server.location,
      config: v2rayUrl.getFullConfiguration(),
      blockedApps: null,
      bypassSubnets: bypassSubnets.isNotEmpty ? bypassSubnets : null,
      proxyOnly: false,
    );

    _currentServer = server;
    _isConnected = true;
  }

  // ── Disconnect ────────────────────────────────────────────────────

  Future<void> disconnect() async {
    await _ensureInitialized();
    await _v2ray.stopV2Ray();
    _isConnected = false;
    _currentServer = null;
  }

  // ── Routing ───────────────────────────────────────────────────────

  void setVtalkOnly(bool enabled) {
    _vtalkOnlyMode = enabled;
    _splitDomains = enabled
        ? ['hypermax.duckdns.org', 'vtalk.io', 'matrix.vtalk.io']
        : [];
  }

  void setCustomDomains(List<String> domains) {
    _vtalkOnlyMode = false;
    _splitDomains = List.from(domains);
  }

  /// Build subnet bypass list from split domains.
  /// flutter_v2ray uses IP ranges — domains resolved at runtime by Xray.
  List<String> _buildBypassList() {
    if (_splitDomains.isEmpty) return [];
    // Pass domains as-is; Xray engine resolves them
    return _splitDomains;
  }

  // ── Helpers ───────────────────────────────────────────────────────

  String _countryFromNodeId(String nodeId) {
    if (nodeId.startsWith('pl')) return 'PL';
    if (nodeId.startsWith('fi')) return 'FI';
    if (nodeId.startsWith('ru')) return 'RU';
    if (nodeId.startsWith('de')) return 'DE';
    return '';
  }

  List<ServerModel> _fallbackServers() {
    return [
      ServerModel.fromJson({
        'id': 'fallback-pl-01',
        'nodeId': 'pl-01',
        'location': 'Poland, Warsaw',
        'countryCode': 'PL',
        'endpoint': 'vpn-pl.vtalk.io:2053',
        'purpose': 'general',
        'capacity': 1000,
        'currentLoad': 0,
        'loadPercentage': 0,
        'configType': 'vless',
        'isAI': false,
        'available': true,
      }),
    ];
  }
}