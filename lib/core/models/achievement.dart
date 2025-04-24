class Achievement {
  final int id;
  final String name;
  final String description;
  final int pointsReward;
  final bool isSecret;
  final String iconPath;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsReward,
    this.isSecret = false,
    required this.iconPath,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      pointsReward: json['pointsReward'],
      isSecret: json['isSecret'] ?? false,
      iconPath: json['iconPath'],
    );
  }
}