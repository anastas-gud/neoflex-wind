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
}