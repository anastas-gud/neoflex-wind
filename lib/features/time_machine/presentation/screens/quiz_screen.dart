import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/constants/colors.dart';
import 'package:neoflex_quest/core/models/question.dart';
import 'package:neoflex_quest/core/models/user.dart';
import 'package:neoflex_quest/core/services/time_machine_service.dart';
import 'package:neoflex_quest/core/services/user_service.dart';

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
  UserService _userService = UserService();

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

  Future<void> _updateUserPoints() async {
    _userService.updateUserPoints(widget.userId, _score);
  }

  void _submitAnswer() async {
    if (_selectedAnswer == null) return;

    setState(() => _isSubmitting = true);

    try {
      final questions = await _questionsFuture;
      final currentQuestion = questions[_currentQuestionIndex];
      final isCorrect = _selectedAnswer == currentQuestion.correctAnswer;

      if (isCorrect) {
        _score += currentQuestion.points;
        _correctAnswers++;
      }

      await _timeMachineService.submitAnswer(
        widget.userId,
        currentQuestion.id,
        _selectedAnswer!,
        isCorrect,
      );

      if (_currentQuestionIndex == questions.length - 1) {
        await _incrementAttempt();
        await _updateUserPoints();
        widget.onUpdate();
        _showResults();
      }

      setState(() {
        if (_currentQuestionIndex < questions.length - 1) {
          _currentQuestionIndex++;
          _selectedAnswer = null;
        }
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      print('Ошибка при отправке ответа: $e');
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Тест завершен!'.toUpperCase(),
          style: TextStyle(color: AppColors.orange),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Правильных ответов: $_correctAnswers из $_totalQuestions',
              style: TextStyle(color: AppColors.purple, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Начислено мандаринок: $_score',
              style: TextStyle(color: AppColors.purple, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Общий баланс: ${widget.user.points + _score}',
              style: TextStyle(color: AppColors.purple, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              widget.onUpdate();
            },
            child: Text(
              'Вернуться'.toUpperCase(),
              style: TextStyle(color: AppColors.softOrange),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.era.toUpperCase(),
          style: const TextStyle(
            fontSize: 25,
            color: AppColors.orange,
            fontWeight: FontWeight.bold,
            letterSpacing: -1.8,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.orange, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
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
          final currentQuestion = questions[_currentQuestionIndex];

          return ScrollConfiguration(
              behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      Scaffold.of(context).appBarMaxHeight! -
                      MediaQuery.of(context).padding.top,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Center(
                      child: Image.asset(
                        'assets/images/time.png',
                        height: 150,
                        width: 150,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.timer_sharp,
                          size: 150,
                          color: AppColors.lightPurple,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Вопрос ${_currentQuestionIndex + 1} / ${questions.length}',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.softOrange,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            currentQuestion.questionText,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.middlePurple,
                            ),
                          ),
                          SizedBox(height: 20),
                          Theme(
                            data: Theme.of(context).copyWith(
                              unselectedWidgetColor: AppColors.lightPurple,
                              radioTheme: RadioThemeData(
                                fillColor: WidgetStateProperty.resolveWith<Color>(
                                      (states) => AppColors.lightPurple,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                RadioListTile<String>(
                                  title: Text(
                                    currentQuestion.option1,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: AppColors.lightPurple,
                                    ),
                                  ),
                                  value: currentQuestion.option1,
                                  groupValue: _selectedAnswer,
                                  onChanged: (value) =>
                                      setState(() => _selectedAnswer = value),
                                ),
                                RadioListTile<String>(
                                  title: Text(
                                    currentQuestion.option2,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: AppColors.lightPurple,
                                    ),
                                  ),
                                  value: currentQuestion.option2,
                                  groupValue: _selectedAnswer,
                                  onChanged: (value) =>
                                      setState(() => _selectedAnswer = value),
                                ),
                                RadioListTile<String>(
                                  title: Text(
                                    currentQuestion.option3,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: AppColors.lightPurple,
                                    ),
                                  ),
                                  value: currentQuestion.option3,
                                  groupValue: _selectedAnswer,
                                  onChanged: (value) =>
                                      setState(() => _selectedAnswer = value),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: _selectedAnswer == null || _isSubmitting
                                  ? null
                                  : _submitAnswer,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: AppColors.orange,
                                backgroundColor: AppColors.white,
                                side: BorderSide(
                                  color: AppColors.orange,
                                  width: 2.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                              child: _isSubmitting
                                  ? CircularProgressIndicator(
                                color: Colors.white,
                              )
                                  : Text(
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.orange,
                                ),
                                _currentQuestionIndex ==
                                    questions.length - 1
                                    ? 'Завершить'.toUpperCase()
                                    : 'Далее'.toUpperCase(),
                              ),
                            ),
                          ),
                          SizedBox(height: 20), // Добавлен отступ снизу
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}