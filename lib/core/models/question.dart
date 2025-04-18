class Question {
  final int id;
  final String era;
  final String questionText;
  final String correctAnswer;
  final List<String> options;
  final int points;

  Question({
    required this.id,
    required this.era,
    required this.questionText,
    required this.correctAnswer,
    required this.options,
    required this.points,
  });
}