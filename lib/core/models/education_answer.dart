class EducationAnswer {
  final int id;
  final int userId;
  final int itemId;
  final String selectedCategory;
  final bool isCorrect;
  final DateTime answeredAt;

  EducationAnswer({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.selectedCategory,
    required this.isCorrect,
    required this.answeredAt,
  });

  factory EducationAnswer.fromJson(Map<String, dynamic> json) {
    return EducationAnswer(
      id: json['id'],
      userId: json['user']['id'],
      itemId: json['item']['id'],
      selectedCategory: json['selectedCategory'],
      isCorrect: json['isCorrect'],
      answeredAt: DateTime.parse(json['answeredAt']),
    );
  }
}