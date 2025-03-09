class User {
  final int id;
  final String name;
  final String email;
  final String token;
  final String hospitalCode;
  final String? profilePicture;
  final String role;
  final bool isOnline;
  final DateTime? lastActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.hospitalCode,
    this.profilePicture,
    required this.role,
    required this.isOnline,
    this.lastActive,
    sta,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      token: json['token'],
      hospitalCode: '',
      profilePicture: json['profile_picture'],
      role: json['role'],
      isOnline: json['is_online'] ?? false,
      lastActive:
          json['last_active'] != null
              ? DateTime.parse(json['last_active'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'hospital_id': hospitalCode,
      'token': token,
      'profile_picture': profilePicture,
      'role': role,
      'is_online': isOnline,
      'last_active': lastActive?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    int? hospitalCode,
    String? profilePicture,
    String? role,
    bool? isOnline,
    DateTime? lastActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      hospitalCode: this.hospitalCode,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
      token: token,
    );
  }
}
