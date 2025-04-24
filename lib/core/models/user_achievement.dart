class UserAchievement {
  final int id;
  final int userId;
  final int achievementId;
  final DateTime earnedAt;

  UserAchievement({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.earnedAt,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      id: json['id'],
      userId: json['user']['id'],
      achievementId: json['achievement']['id'],
      earnedAt: DateTime.parse(json['earnedAt']),
    );
  }
}
