class UserAnswer {
  final int id;
  final int userId;
  final int questionId;
  final String answer;
  final bool isCorrect;
  final DateTime answeredAt;

  UserAnswer({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.answer,
    required this.isCorrect,
    required this.answeredAt,
  });

  factory UserAnswer.fromJson(Map<String, dynamic> json) {
    return UserAnswer(
      id: json['id'],
      userId: json['user']['id'],
      questionId: json['question']['id'],
      answer: json['answer'],
      isCorrect: json['isCorrect'],
      answeredAt: DateTime.parse(json['answeredAt']),
    );
  }
}