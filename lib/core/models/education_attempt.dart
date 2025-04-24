class EducationAttempt {
  final int id;
  final int userId;
  final int attemptsUsed;
  final DateTime? lastAttempt;
  final int maxAttempts;

  EducationAttempt({
    required this.id,
    required this.userId,
    required this.attemptsUsed,
    required this.lastAttempt,
    required this.maxAttempts,
  });

  factory EducationAttempt.fromJson(Map<String, dynamic> json) {
    return EducationAttempt(
      id: json['id'],
      userId: json['user']['id'],
      attemptsUsed: json['attemptsUsed'] ?? 0,
      lastAttempt: json['lastAttempt'] != null ? DateTime.parse(json['lastAttempt']) : null,
      maxAttempts: json['maxAttempts'] ?? 3,
    );
  }
}
