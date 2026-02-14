/// VPN Service Stub – NekoBox/sing-box compatible
///
/// Design reference: NekoBoxForAndroid (sing-box core)
/// https://github.com/MatsuriDayo/NekoBoxForAndroid
///
/// Supports protocol types: SOCKS5, HTTP(S), VLESS, Reality (and placeholders).
/// Ready for future native/FFI integration with sing-box.

enum VPNProtocol {
  socks5,
  http,
  https,
  vless,
  reality,
  // Placeholders for full NekoBox set
  vmess,
  trojan,
  shadowsocks,
}

/// Outbound profile (node) – mirrors sing-box outbound structure.
class VPNOutbound {
  final String tag;
  final VPNProtocol protocol;
  final String server;
  final int serverPort;
  final Map<String, dynamic>? protocolOptions;

  const VPNOutbound({
    required this.tag,
    required this.protocol,
    required this.server,
    required this.serverPort,
    this.protocolOptions,
  });

  Map<String, dynamic> toMap() {
    return {
      'tag': tag,
      'type': protocol.name,
      'server': server,
      'server_port': serverPort,
      ...?protocolOptions,
    };
  }
}

/// SOCKS5 outbound options (NekoBox/sing-box style).
class Socks5Options {
  final String? username;
  final String? password;
  final String? version; // "5"

  const Socks5Options({this.username, this.password, this.version});
}

/// HTTP(S) outbound options.
class HTTPOptions {
  final String? username;
  final String? password;
  final bool tls;

  const HTTPOptions({this.username, this.password, this.tls = false});
}

/// VLESS outbound options (UUID, flow, etc.).
class VLESSOptions {
  final String uuid;
  final String? flow;
  final int? level;
  final String? encryption;

  const VLESSOptions({
    required this.uuid,
    this.flow,
    this.level,
    this.encryption,
  });
}

/// Reality (VLESS Reality) outbound options.
class RealityOptions {
  final String uuid;
  final String? flow;
  final String publicKey;
  final String shortId;
  final String serverName; // SNI
  final String? spiderYaml;
  final int? level;

  const RealityOptions({
    required this.uuid,
    this.flow,
    required this.publicKey,
    required this.shortId,
    required this.serverName,
    this.spiderYaml,
    this.level,
  });
}

/// VPN connection status.
enum VPNStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

/// Service interface – stub implementation.
/// Actual connect/disconnect will be implemented via platform channel or FFI.
class VPNService {
  VPNStatus _status = VPNStatus.disconnected;
  VPNStatus get status => _status;

  /// Stub: prepare and validate outbound (no real connection).
  Future<bool> validateOutbound(VPNOutbound outbound) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return outbound.server.isNotEmpty && outbound.serverPort > 0;
  }

  /// Stub: connect with given outbound (NekoBox/sing-box pattern).
  Future<void> connect(VPNOutbound outbound) async {
    if (_status == VPNStatus.connected) await disconnect();
    _status = VPNStatus.connecting;
    await Future.delayed(const Duration(seconds: 1));
    _status = VPNStatus.connected;
  }

  /// Stub: disconnect.
  Future<void> disconnect() async {
    _status = VPNStatus.disconnecting;
    await Future.delayed(const Duration(milliseconds: 300));
    _status = VPNStatus.disconnected;
  }

  /// Stub: toggle (connect if disconnected, else disconnect).
  Future<void> toggle(VPNOutbound? outbound) async {
    if (_status == VPNStatus.connected) {
      await disconnect();
    } else if (outbound != null) {
      await connect(outbound);
    }
  }
}
