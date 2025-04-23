import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/models/question.dart';
import 'package:neoflex_quest/core/models/user.dart';
import '../../../../core/database/database_service.dart';

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

  @override
  void initState() {
    super.initState();
    _questionsFuture = _loadQuestions().then((questions) {
      _totalQuestions = questions.length;
      return questions;
    });
  }

  Future<List<Question>> _loadQuestions() async {
    final connection = await DatabaseService().getConnection();
    try {
      final results = await connection.query(
        'SELECT * FROM time_machine_questions WHERE era = @era',
        substitutionValues: {'era': widget.era},
      );

      return results.map((row) => Question(
        id: row[0] as int,
        era: row[1] as String,
        questionText: row[2] as String,
        correctAnswer: row[3] as String,
        options: [
          if (row[4] != null) row[4] as String,
          if (row[5] != null) row[5] as String,
          if (row[6] != null) row[6] as String,
        ],
        points: row[7] as int,
      )).toList();
    } finally {
      await connection.close();
    }
  }

  Future<void> _incrementAttempt() async {
    final connection = await DatabaseService().getConnection();
    try {
      await connection.query('''
        INSERT INTO public.test_attempts (user_id, era, attempts_used, last_attempt)
        VALUES (@userId, @era, 1, CURRENT_TIMESTAMP)
        ON CONFLICT (user_id, era) 
        DO UPDATE SET 
          attempts_used = LEAST(test_attempts.attempts_used + 1, 3),
          last_attempt = CURRENT_TIMESTAMP
      ''', substitutionValues: {
        'userId': widget.userId,
        'era': widget.era,
      });
    } finally {
      await connection.close();
    }
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
        substitutionValues: {
          'points': _score,
          'userId': widget.userId,
        },
      );
    } finally {
      await connection.close();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Тест завершен!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Правильных ответов: $_correctAnswers из $_totalQuestions'),
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
                    questions[_currentQuestionIndex].questionText,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ...questions[_currentQuestionIndex].options.map((option) => RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _selectedAnswer,
                    onChanged: (value) => setState(() => _selectedAnswer = value),
                  )),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _selectedAnswer == null || _isSubmitting
                          ? null
                          : _submitAnswer,
                      child: _isSubmitting
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(_currentQuestionIndex == questions.length - 1
                          ? 'Завершить'
                          : 'Далее'),
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