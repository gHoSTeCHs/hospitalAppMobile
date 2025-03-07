class User {
  final int id;
  final String name;
  final String email;
  final String token;
  final String hospitalCode;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.hospitalCode,
    sta,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user']['id'],
      name: json['user']['name'],
      email: json['user']['email'],
      token: json['token'],
      hospitalCode: '',
    );
  }
}
