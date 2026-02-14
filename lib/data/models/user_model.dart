class User {
  final String id;
  final String username;
  final String email;
  final String vtNumber;
  final bool isPremium;
  final String? activationCode;
  final DateTime? createdAt;
  final DateTime? premiumExpiresAt;  // ⭐ ДОБАВИТЬ
  final String? avatar;  // 🚨 ДОБАВИТЬ АВАТАР
  final String? status;  // 🚨 ДОБАВИТЬ СТАТУС

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.vtNumber,
    this.isPremium = false,
    this.activationCode,
    this.createdAt,
    this.premiumExpiresAt,  // ⭐ ДОБАВИТЬ
    this.avatar,  // 🚨 ДОБАВИТЬ АВАТАР
    this.status,  // 🚨 ДОБАВИТЬ СТАТУС
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Авто-генерация ника из email если username пустой
    final username = json['username']?.toString() ?? 
                  (json['email']?.toString().split('@')[0] ?? 'User');
    
    // Парсим premiumExpiresAt если есть
    DateTime? premiumExpiresAt;
    if (json['premiumExpiresAt'] != null) {
      premiumExpiresAt = DateTime.parse(json['premiumExpiresAt']);
    }
    
    return User(
      id: json['id']?.toString() ?? '',
      username: username,
      email: json['email']?.toString() ?? '',
      vtNumber: json['vtNumber']?.toString() ?? '',
      isPremium: json['isPremium'] ?? false,
      activationCode: json['activationCode'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      premiumExpiresAt: premiumExpiresAt,  // ⭐ ДОБАВИТЬ
      avatar: json['avatar'],  // 🚨 ДОБАВИТЬ АВАТАР
      status: json['status'],  // 🚨 ДОБАВИТЬ СТАТУС
    );
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
      'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),  // ⭐ ДОБАВИТЬ
      'avatar': avatar,  // 🚨 ДОБАВИТЬ АВАТАР
      'status': status,  // 🚨 ДОБАВИТЬ СТАТУС
    };
  }

  // ⭐ GRACE PERIOD - ПРОВЕРКА ДОСТУПА
  bool hasAccess() {
    if (isPremium) return true;
    if (premiumExpiresAt == null) return false;
    
    // Добавляем 24 часа к дате истечения
    final gracePeriodEnd = premiumExpiresAt!.add(const Duration(hours: 24));
    return DateTime.now().isBefore(gracePeriodEnd);
  }

  // ⭐ ФОРМАТИРОВАННАЯ ДАТА ДЛЯ UI
  String get premiumExpiresFormatted {
    if (premiumExpiresAt == null) return 'Не указана';
    
    final date = premiumExpiresAt!;
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  // ⭐ СТАТУС PREMIUM ДЛЯ UI
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
    DateTime? premiumExpiresAt,  // ⭐ ДОБАВИТЬ
    String? avatar,  // 🚨 ДОБАВИТЬ АВАТАР
    String? status,  // 🚨 ДОБАВИТЬ СТАТУС
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      vtNumber: vtNumber ?? this.vtNumber,
      isPremium: isPremium ?? this.isPremium,
      activationCode: activationCode ?? this.activationCode,
      createdAt: createdAt ?? this.createdAt,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,  // ⭐ ДОБАВИТЬ
      avatar: avatar ?? this.avatar,  // 🚨 ДОБАВИТЬ АВАТАР
      status: status ?? this.status,  // 🚨 ДОБАВИТЬ СТАТУС
    );
  }
}
