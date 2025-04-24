class User {
  final int id;
  final String username;
  final String email;
  final int points;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.points,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      points: json['points'] ?? 0,
    );
  }
}
