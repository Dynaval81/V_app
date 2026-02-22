/// Canonical User model. Single source of truth.
/// Path: lib/data/models/user_model.dart
///
/// lib/models/user_model.dart — DELETED (duplicate with broken encoding)
class User {
  final String id;
  final String username;
  final String email;
  final String vtNumber;
  final bool isPremium;
  final String? activationCode;
  final DateTime? createdAt;
  final DateTime? premiumExpiresAt;
  final String? avatar;
  final String? status;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.vtNumber,
    this.isPremium = false,
    this.activationCode,
    this.createdAt,
    this.premiumExpiresAt,
    this.avatar,
    this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Auto-generate username from email if missing
    final username = json['username']?.toString() ??
        (json['email']?.toString().split('@')[0] ?? 'User');

    return User(
      id: json['id']?.toString() ?? '',
      username: username,
      email: json['email']?.toString() ?? '',
      vtNumber: json['vtNumber']?.toString() ?? '',
      isPremium: json['isPremium'] ?? false,
      activationCode: json['activationCode']?.toString(),
      createdAt: _parseDate(json['createdAt']),
      premiumExpiresAt: _parseDate(json['premiumExpiresAt']),
      avatar: json['avatar']?.toString(),
      status: json['status']?.toString(),
    );
  }

  /// Safe date parser — returns null instead of crashing on malformed input.
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'vtNumber': vtNumber,
      'isPremium': isPremium,
      'activationCode': activationCode,
      'createdAt': createdAt?.toIso8601String(),
      'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
      'avatar': avatar,
      'status': status,
    };
  }

  // ── Premium helpers ───────────────────────────────────────────────

  /// True if premium active OR within 24h grace period after expiry.
  bool hasAccess() {
    if (isPremium) return true;
    if (premiumExpiresAt == null) return false;
    final gracePeriodEnd = premiumExpiresAt!.add(const Duration(hours: 24));
    return DateTime.now().isBefore(gracePeriodEnd);
  }

  String get premiumExpiresFormatted {
    if (premiumExpiresAt == null) return 'Не указана';
    final d = premiumExpiresAt!;
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  String get premiumStatus {
    if (isPremium) return 'Premium активен';
    if (premiumExpiresAt == null) return 'Premium не активен';
    final gracePeriodEnd = premiumExpiresAt!.add(const Duration(hours: 24));
    if (DateTime.now().isBefore(gracePeriodEnd)) {
      return 'Grace Period (льготный период)';
    }
    return 'Premium истек';
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? vtNumber,
    bool? isPremium,
    String? activationCode,
    DateTime? createdAt,
    DateTime? premiumExpiresAt,
    String? avatar,
    String? status,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      vtNumber: vtNumber ?? this.vtNumber,
      isPremium: isPremium ?? this.isPremium,
      activationCode: activationCode ?? this.activationCode,
      createdAt: createdAt ?? this.createdAt,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
    );
  }
}