/// VPN Server model — matches GET /api/v1/vpn/servers response.
/// Path: lib/data/models/server_model.dart
class ServerModel {
  final String id;
  final String nodeId;
  final String location;
  final String countryCode;
  final String endpoint;
  final String purpose; // "general" | "reverse"
  final int capacity;
  final int currentLoad;
  final int loadPercentage;
  final String configType; // "vless" | "singbox"
  final bool isAI;
  final bool available;

  // Populated after GET /vpn/config/:nodeId
  final String? vlessUri;

  const ServerModel({
    required this.id,
    required this.nodeId,
    required this.location,
    required this.countryCode,
    required this.endpoint,
    required this.purpose,
    required this.capacity,
    required this.currentLoad,
    required this.loadPercentage,
    required this.configType,
    required this.isAI,
    required this.available,
    this.vlessUri,
  });

  factory ServerModel.fromJson(Map<String, dynamic> json) {
    return ServerModel(
      id: json['id']?.toString() ?? '',
      nodeId: json['nodeId']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      countryCode: json['countryCode']?.toString() ?? '',
      endpoint: json['endpoint']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? 'general',
      capacity: (json['capacity'] as num?)?.toInt() ?? 1000,
      currentLoad: (json['currentLoad'] as num?)?.toInt() ?? 0,
      loadPercentage: (json['loadPercentage'] as num?)?.toInt() ?? 0,
      configType: json['configType']?.toString() ?? 'vless',
      isAI: json['isAI'] ?? false,
      available: json['available'] ?? true,
      vlessUri: json['vlessUri']?.toString(),
    );
  }

  ServerModel copyWith({String? vlessUri}) {
    return ServerModel(
      id: id,
      nodeId: nodeId,
      location: location,
      countryCode: countryCode,
      endpoint: endpoint,
      purpose: purpose,
      capacity: capacity,
      currentLoad: currentLoad,
      loadPercentage: loadPercentage,
      configType: configType,
      isAI: isAI,
      available: available,
      vlessUri: vlessUri ?? this.vlessUri,
    );
  }

  /// Flag emoji from countryCode
  String get flagEmoji {
    if (countryCode.isEmpty) return '🌐';
    return countryCode.toUpperCase().split('').map((c) {
      return String.fromCharCode(c.codeUnitAt(0) + 127397);
    }).join();
  }

  /// Host extracted from endpoint (e.g. "vpn-pl.vtalk.io:2053" → "vpn-pl.vtalk.io")
  String get host {
    final parts = endpoint.split(':');
    return parts.isNotEmpty ? parts[0] : endpoint;
  }

  /// Port extracted from endpoint
  int get port {
    final parts = endpoint.split(':');
    return parts.length > 1 ? int.tryParse(parts[1]) ?? 2053 : 2053;
  }

  String get displayName => '$flagEmoji $location';

  String get loadLabel {
    if (loadPercentage < 30) return 'Low';
    if (loadPercentage < 70) return 'Medium';
    return 'High';
  }
}