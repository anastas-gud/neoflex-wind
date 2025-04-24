class Question {
  final int id;
  final String era;
  final String questionText;
  final String correctAnswer;
  final String option1;
  final String option2;
  final String option3;
  final int points;

  Question({
    required this.id,
    required this.era,
    required this.questionText,
    required this.correctAnswer,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.points,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      era: json['era'],
      questionText: json['questionText'],
      correctAnswer: json['correctAnswer'],
      option1: json['option1'],
      option2: json['option2'],
      option3: json['option3'],
      points: json['points'],
    );
  }
}