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
}