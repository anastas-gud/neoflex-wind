import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/models/question.dart';
import 'package:neoflex_quest/core/models/user.dart';
import 'package:neoflex_quest/core/database/database_service.dart';
import 'package:neoflex_quest/core/services/data_service.dart';
import 'package:neoflex_quest/core/services/time_machine_service.dart';

class QuizScreen extends StatefulWidget {
  final int userId;
  final String era;
  final User user;
  final VoidCallback onUpdate;

  const QuizScreen({
    required this.userId,
    required this.era,
    required this.user,
    required this.onUpdate,
    Key? key,
  }) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<Question>> _questionsFuture;
  int _totalQuestions = 0;
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  int _score = 0;
  int _correctAnswers = 0;
  bool _isSubmitting = false;

  TimeMachineService _timeMachineService = TimeMachineService();

  @override
  void initState() {
    super.initState();
    _questionsFuture = _loadQuestions().then((questions) {
      _totalQuestions = questions.length;
      return questions;
    });
  }

  Future<List<Question>> _loadQuestions() async {
    List<Question> result = await _timeMachineService.findQuestionsByEra(
      widget.era,
    );
    return result;
  }

  Future<void> _incrementAttempt() async {
    await _timeMachineService.incrementAttempt(widget.userId, widget.era);
  }

  void _submitAnswer() async {
    if (_selectedAnswer == null) return;

    setState(() => _isSubmitting = true);

    final questions = await _questionsFuture;
    final currentQuestion = questions[_currentQuestionIndex];
    final isCorrect = _selectedAnswer == currentQuestion.correctAnswer;

    if (isCorrect) {
      _score += currentQuestion.points;
      _correctAnswers++;
    }

    final connection = await DatabaseService().getConnection();
    try {
      await connection.query(
        'INSERT INTO user_answers (user_id, question_id, answer, is_correct) '
        'VALUES (@userId, @questionId, @answer, @isCorrect) '
        'ON CONFLICT (user_id, question_id) DO UPDATE '
        'SET answer = @answer, is_correct = @isCorrect',
        substitutionValues: {
          'userId': widget.userId,
          'questionId': currentQuestion.id,
          'answer': _selectedAnswer!,
          'isCorrect': isCorrect,
        },
      );

      if (_currentQuestionIndex == questions.length - 1) {
        await _incrementAttempt(); // Увеличиваем счетчик попыток только после завершения теста
        await _updateUserPoints();
        widget.onUpdate(); // Вызываем callback для обновления главного экрана
      }
    } finally {
      await connection.close();
    }

    if (_currentQuestionIndex < questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _isSubmitting = false;
      });
    } else {
      setState(() => _isSubmitting = false);
      _showResults();
    }
  }

  Future<void> _updateUserPoints() async {
    final connection = await DatabaseService().getConnection();
    try {
      await connection.query(
        'UPDATE users SET points = points + @points WHERE id = @userId',
        substitutionValues: {'points': _score, 'userId': widget.userId},
      );
    } finally {
      await connection.close();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text('Тест завершен!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Правильных ответов: $_correctAnswers из $_totalQuestions',
                ),
                SizedBox(height: 8),
                Text('Начислено мандаринок: $_score'),
                SizedBox(height: 8),
                Text('Общий баланс: ${widget.user.points + _score}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('Вернуться'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.era)),
      body: FutureBuilder<List<Question>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки вопросов'));
          }

          final questions = snapshot.data!;
          final currentQuestion = questions[_currentQuestionIndex];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Вопрос ${_currentQuestionIndex + 1}/${questions.length}',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  Text(
                    currentQuestion.questionText,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  RadioListTile<String>(
                    title: Text(currentQuestion.option1),
                    value: currentQuestion.option1,
                    groupValue: _selectedAnswer,
                    onChanged:
                        (value) => setState(() => _selectedAnswer = value),
                  ),
                  RadioListTile<String>(
                    title: Text(currentQuestion.option2),
                    value: currentQuestion.option2,
                    groupValue: _selectedAnswer,
                    onChanged:
                        (value) => setState(() => _selectedAnswer = value),
                  ),
                  RadioListTile<String>(
                    title: Text(currentQuestion.option3),
                    value: currentQuestion.option3,
                    groupValue: _selectedAnswer,
                    onChanged:
                        (value) => setState(() => _selectedAnswer = value),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed:
                          _selectedAnswer == null || _isSubmitting
                              ? null
                              : _submitAnswer,
                      child:
                          _isSubmitting
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                _currentQuestionIndex == questions.length - 1
                                    ? 'Завершить'
                                    : 'Далее',
                              ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
