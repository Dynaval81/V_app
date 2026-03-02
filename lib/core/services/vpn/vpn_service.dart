import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_singbox_vpn/flutter_singbox.dart';
import 'package:http/http.dart' as http;
import 'package:vtalk_app/data/models/server_model.dart';
import 'package:vtalk_app/services/api_service.dart';

/// VPN engine — sing-box based, TUN mode, works without root.
class VPNService {
  final ApiService _api = ApiService();
  final FlutterSingbox _singbox = FlutterSingbox();

  bool _isConnected = false;
  ServerModel? _currentServer;
  bool _splitTunnelingEnabled = false;
  List<String> _splitApps = [];
  List<String> _splitDomains = [];

  bool get isConnected => _isConnected;
  ServerModel? get currentServer => _currentServer;
  bool get isSplitTunnelingEnabled => _splitTunnelingEnabled;
  List<String> get splitApps => List.unmodifiable(_splitApps);
  List<String> get splitDomains => List.unmodifiable(_splitDomains);

  Future<void> initialize(void Function(bool connected) onStatusChanged) async {
    _singbox.setNotificationTitle('VTalk VPN');
    _singbox.setNotificationDescription('Защищённое соединение активно');

    _singbox.onStatusChanged.listen((event) {
      final status = event['status'] as String?;
      final connected = status == VPNStatus.STARTED;
      _isConnected = connected;
      onStatusChanged(connected);
    });
  }

  Future<List<ServerModel>> loadServers({String? purpose}) async {
    try {
      final result = await _api.getVpnServers(purpose: purpose);
      if (result['success'] == true) {
        final list = result['servers'] as List<dynamic>;
        return list
            .map((e) => ServerModel.fromJson(e as Map<String, dynamic>))
            .where((s) => s.available && !_isFakeServer(s))
            .toList();
      }
    } catch (e) {
      debugPrint('[VPN] loadServers error: $e');
    }
    return [];
  }

  bool _isFakeServer(ServerModel s) {
    final loc = s.location.toUpperCase();
    final id = s.nodeId.toUpperCase();
    return loc.contains('FAKE') || loc.contains('TEST ONLY') ||
        id == 'FI-01' || id == 'RU-REVERSE';
  }

  Future<ServerModel?> loadConfig(String nodeId) async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
          return null;
      }

      const base = 'https://hypermax.duckdns.org/api/v1';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final resp = await http.get(
        Uri.parse('$base/vpn/config/$nodeId'),
        headers: headers,
      );

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final nodeData = (data['data'] ?? data) as Map<String, dynamic>;
      final vlessUri = nodeData['vlessUri'] as String?;

      return ServerModel.fromJson({
        'id': nodeData['nodeId'] ?? nodeId,
        'nodeId': nodeData['nodeId'] ?? nodeId,
        'location': nodeData['location'] ?? '',
        'countryCode': _countryFromNodeId(nodeId),
        'endpoint': nodeData['endpoint'] ?? '',
        'purpose': 'general',
        'capacity': 1000,
        'currentLoad': 0,
        'loadPercentage': 0,
        'configType': nodeData['configType'] ?? 'vless',
        'isAI': false,
        'available': true,
        'vlessUri': vlessUri,
        'xrayConfig': null,
      });
    } catch (e) {
      debugPrint('[VPN] loadConfig error: $e');
    }
    return null;
  }

  Future<int?> pingServer(ServerModel server) async {
    try {
      final sw = Stopwatch()..start();
      final resp = await http
          .get(Uri.parse('https://www.gstatic.com/generate_204'))
          .timeout(const Duration(seconds: 3));
      sw.stop();
      return resp.statusCode == 204 ? sw.elapsedMilliseconds : null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, int?>> pingAll(List<ServerModel> servers) async {
    if (servers.isEmpty) return {};
    final ms = await pingServer(servers.first);
    return {for (final s in servers) s.nodeId: ms};
  }

  Future<ServerModel?> pickFastest(List<ServerModel> servers) async {
    if (servers.isEmpty) return null;
    final pings = await pingAll(servers);
    servers.sort((a, b) =>
        (pings[a.nodeId] ?? 9999).compareTo(pings[b.nodeId] ?? 9999));
    return servers.first;
  }

  Future<void> connect(ServerModel server) async {
    final uri = server.vlessUri;

    if (uri == null || uri.isEmpty) {
      throw Exception('No VLESS URI for node ${server.nodeId}');
    }

    final singboxConfig = _buildSingboxConfig(uri);

    final saved = await _singbox.saveConfig(jsonEncode(singboxConfig));
    if (!saved) throw Exception('Failed to save sing-box config');

    final started = await _singbox.startVPN();
    if (!started) throw Exception('Failed to start VPN');

    _currentServer = server;
  }

  Future<void> disconnect() async {
    await _singbox.stopVPN();
    _isConnected = false;
    _currentServer = null;
  }

  Future<void> setSplitTunneling({
    required List<String> apps,
    required List<String> domains,
    required bool enabled,
  }) async {
    _splitApps = List.from(apps);
    _splitDomains = List.from(domains);
    _splitTunnelingEnabled = enabled;

    // Если VPN уже подключён — переподключаем с новым конфигом
    if (_isConnected && _currentServer != null) {
      await disconnect();
      await Future.delayed(const Duration(milliseconds: 500));
      await connect(_currentServer!);
    }
  }

  Future<void> selectServer(ServerModel server) async {
    _currentServer = server;
  }

  Map<String, dynamic> _buildSingboxConfig(String vlessUri) {
    // Parse: vless://UUID@HOST:PORT?params#name
    final uri = Uri.parse(vlessUri);
    final uuid = uri.userInfo;
    final host = uri.host;
    final port = uri.port;
    final params = uri.queryParameters;

    final pbk  = params['pbk'] ?? '';
    final sni  = params['sni'] ?? host;
    final sid  = params['sid'] ?? '';
    final fp   = params['fp'] ?? 'chrome';
    final flow = params['flow'] ?? '';

    // Private IP ranges — replaces deprecated geoip:private
    const privateRanges = [
      '0.0.0.0/8',
      '10.0.0.0/8',
      '100.64.0.0/10',
      '127.0.0.0/8',
      '169.254.0.0/16',
      '172.16.0.0/12',
      '192.0.0.0/24',
      '192.168.0.0/16',
      '198.18.0.0/15',
      '198.51.100.0/24',
      '203.0.113.0/24',
      '240.0.0.0/4',
      '255.255.255.255/32',
      '::1/128',
      'fc00::/7',
      'fe80::/10',
    ];

    final routeRules = <Map<String, dynamic>>[
      {'protocol': 'dns', 'outbound': 'dns-out'},
      {'ip_cidr': privateRanges, 'outbound': 'direct'},
      // STUN/TURN для звонков Telegram, WhatsApp, WebRTC
      {'protocol': 'stun', 'outbound': 'direct'},
      {'port': [3478, 3479, 5349, 19302, 19303, 19304, 19305, 19306, 19307, 19308, 19309], 'outbound': 'direct'},
      // Split tunneling: только выбранные приложения/домены через VPN, остальное direct
      if (_splitTunnelingEnabled) ...([
        if (_splitApps.isNotEmpty)
          {'android_package_names': _splitApps, 'outbound': 'proxy'},
        if (_splitDomains.isNotEmpty)
          {'domain': _splitDomains, 'outbound': 'proxy'},
        {'outbound': 'direct'},
      ]),
    ];

    return {
      'log': {'level': 'info', 'disabled': false, 'timestamp': true},
      'dns': {
        'servers': [
          {
            'tag': 'remote-dns',
            'address': 'tls://1.1.1.1',
            'detour': 'proxy',
          },
          {
            'tag': 'local-dns',
            'address': 'local',
            'detour': 'direct',
          },
        ],
        'rules': [
          {'outbound': 'any', 'server': 'local-dns'},
        ],
        'final': 'remote-dns',
        'strategy': 'prefer_ipv4',
      },
      'inbounds': [
        {
          'type': 'tun',
          'tag': 'tun-in',
          'interface_name': 'tun0',
          'inet4_address': '172.19.0.1/30',
          'mtu': 1400,
          'auto_route': true,
          'strict_route': false,
          'stack': 'mixed',
          'sniff': true,
          'sniff_override_destination': false,
          'domain_strategy': 'ipv4_only',
        }
      ],
      'outbounds': [
        {
          'tag': 'proxy',
          'type': 'vless',
          'server': host,
          'server_port': port,
          'uuid': uuid,
          if (flow.isNotEmpty) 'flow': flow,
          'tls': {
            'enabled': true,
            'server_name': sni,
            'reality': {
              'enabled': true,
              'public_key': pbk,
              'short_id': sid,
            },
            'utls': {
              'enabled': true,
              'fingerprint': fp,
            },
          },
          'packet_encoding': 'xudp',
        },
        {'tag': 'direct', 'type': 'direct'},
        {'tag': 'dns-out', 'type': 'dns'},
      ],
      'route': {
        'auto_detect_interface': true,
        // Если split tunneling — дефолт direct, иначе всё через proxy
        'final': _splitTunnelingEnabled ? 'direct' : 'proxy',
        'rules': routeRules,
      },
    };
  }

  String _countryFromNodeId(String nodeId) {
    final id = nodeId.toUpperCase();
    if (id.startsWith('PL')) return 'PL';
    if (id.startsWith('FI')) return 'FI';
    if (id.startsWith('DE')) return 'DE';
    if (id.startsWith('US')) return 'US';
    if (id.startsWith('RU')) return 'RU';
    if (id.startsWith('NL')) return 'NL';
    if (id.startsWith('GB') || id.startsWith('UK')) return 'GB';
    return 'XX';
  }
}