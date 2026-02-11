class User {
  final String id;
  final String username;
  final String email;
  final String vtNumber;
  final bool isPremium;
  final String? activationCode;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.vtNumber,
    this.isPremium = false,
    this.activationCode,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      vtNumber: json['vtNumber']?.toString() ?? '',
      isPremium: json['isPremium'] ?? false,
      activationCode: json['activationCode'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
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
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? vtNumber,
    bool? isPremium,
    String? activationCode,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      vtNumber: vtNumber ?? this.vtNumber,
      isPremium: isPremium ?? this.isPremium,
      activationCode: activationCode ?? this.activationCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
