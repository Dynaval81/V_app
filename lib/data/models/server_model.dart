/// Server/location model for VPN selection (NekoBox-style).
class ServerModel {
  final String id;
  final String name;
  final String countryCode;
  final String? flagEmoji;
  final String host;
  final int port;
  final bool isPremium;

  const ServerModel({
    required this.id,
    required this.name,
    required this.countryCode,
    this.flagEmoji,
    required this.host,
    required this.port,
    this.isPremium = false,
  });

  String get displayName => flagEmoji != null ? '$flagEmoji $name' : name;
}
