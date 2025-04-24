class TestAttempt {
  final int id;
  final int userId;
  final String era;
  final int attemptsUsed;
  final DateTime? lastAttempt;

  TestAttempt({
    required this.id,
    required this.userId,
    required this.era,
    required this.attemptsUsed,
    required this.lastAttempt,
  });

  factory TestAttempt.fromJson(Map<String, dynamic> json) {
    return TestAttempt(
      id: json['id'],
      userId: json['user']['id'],
      era: json['era'],
      attemptsUsed: json['attemptsUsed'] ?? 0,
      lastAttempt: json['lastAttempt'] != null ? DateTime.parse(json['lastAttempt']) : null,
    );
  }
}