import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/models/question.dart';

import '../../../../core/database/database_service.dart';

class QuizScreen extends StatefulWidget {
  final int userId;
  final String era;

  const QuizScreen({
    required this.userId,
    required this.era,
    Key? key,
  }) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<Question>> _questionsFuture;
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  int _score = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _loadQuestions();
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

  void _submitAnswer() async {
    if (_selectedAnswer == null) return;

    setState(() => _isSubmitting = true);

    final questions = await _questionsFuture;
    final currentQuestion = questions[_currentQuestionIndex];
    final isCorrect = _selectedAnswer == currentQuestion.correctAnswer;

    if (isCorrect) {
      _score += currentQuestion.points;
    }

    // Сохраняем ответ в базу данных
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
      // Тест завершен
      setState(() => _isSubmitting = false);
      _showResults();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Тест завершен!'),
        content: Text('Вы набрали $_score мандаринок'),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: Text('Вернуться'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.era),
      ),
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

          if (_currentQuestionIndex >= questions.length) {
            return _buildResultsScreen();
          }

          final question = questions[_currentQuestionIndex];

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
                    question.questionText,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ...question.options.map((option) => RadioListTile<String>(
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

  Widget _buildResultsScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Тест завершен!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            'Вы набрали $_score мандаринок',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Вернуться'),
          ),
        ],
      ),
    );
  }
}