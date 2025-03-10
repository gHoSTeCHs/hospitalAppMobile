class User {
  final int id;
  final String name;
  final String email;
  final String token;
  final String hospitalCode;
  final String? profilePicture;
  final bool isOnline;
  final DateTime? lastActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.hospitalCode,
    this.profilePicture,

    required this.isOnline,
    this.lastActive,
    sta,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user']['id'],
      name: json['user']['name'],
      email: json['user']['email'],
      token: json['token'],
      hospitalCode: '',
      profilePicture: json['profile_picture'],
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
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
      token: token,
    );
  }
}
