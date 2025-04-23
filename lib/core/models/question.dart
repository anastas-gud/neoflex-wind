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
}