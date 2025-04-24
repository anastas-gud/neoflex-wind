import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/constants/colors.dart';
import 'package:neoflex_quest/core/constants/strings.dart';
import 'package:neoflex_quest/core/models/test_attempt.dart';
import 'package:neoflex_quest/core/services/user_service.dart';
import 'package:neoflex_quest/core/services/time_machine_service.dart';
import 'package:neoflex_quest/features/time_machine/presentation/screens/quiz_screen.dart';
import 'package:neoflex_quest/features/time_machine/presentation/widgets/era_card.dart';
import 'package:neoflex_quest/shared/widgets/small_mascot_widget.dart';

class TimeMachineScreen extends StatefulWidget {
  final int userId;
  final VoidCallback onUpdate;

  const TimeMachineScreen({
    required this.userId,
    required this.onUpdate,
    Key? key,
  }) : super(key: key);

  @override
  _TimeMachineScreenState createState() => _TimeMachineScreenState();
}

class _TimeMachineScreenState extends State<TimeMachineScreen> {
  late Map<String, int> _attemptsRemaining = {
    'Рождение кода (2005-2016)': 3,
    'Эпоха прорыва (2017-2019)': 3,
    'Цифровая революция (2020-2023)': 3,
  };

  final TimeMachineService _timeMachineService = TimeMachineService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadAttempts();
  }

  Future<void> _loadAttempts() async {
    final List<TestAttempt> usersTestAttempts = await _timeMachineService
        .findUsersTestAttempts(widget.userId);
    setState(() {
      for (TestAttempt attempt in usersTestAttempts) {
        String displayEra = _getDisplayEraName(attempt.era);
        int used = attempt.attemptsUsed;
        if (_attemptsRemaining.containsKey(displayEra)) {
          if (3 - used < _attemptsRemaining[displayEra]!) {
            _attemptsRemaining[displayEra] = 3 - used;
          }
        }
      }
    });
  }

  String _getDisplayEraName(String dbEra) {
    switch (dbEra) {
      case 'Рождение кода':
        return 'Рождение кода (2005-2016)';
      case 'Эпоха прорыва':
        return 'Эпоха прорыва (2017-2019)';
      case 'Цифровая революция':
        return 'Цифровая революция (2020-2023)';
      default:
        return dbEra;
    }
  }

  String _getDbEraName(String displayEra) {
    if (displayEra.startsWith('Рождение кода')) return 'Рождение кода';
    if (displayEra.startsWith('Эпоха прорыва')) return 'Эпоха прорыва';
    if (displayEra.startsWith('Цифровая революция'))
      return 'Цифровая революция';
    return displayEra;
  }

  void _navigateToQuiz(BuildContext context, String displayEra) async {
    final dbEra = _getDbEraName(displayEra);
    final attemptsLeft = _attemptsRemaining[displayEra] ?? 3;

    if (attemptsLeft <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Попытки исчерпаны для этой эпохи')),
      );
      return;
    }

    final user = await _userService.getUserById(widget.userId);
    if (user == null) throw Exception('Пользователь не найден');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => QuizScreen(
              userId: widget.userId,
              era: dbEra,
              user: user,
              onUpdate: () {
                widget.onUpdate();
                _loadAttempts(); // Обновляем попытки после завершения теста
              },
            ),
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
          'Машина времени'.toUpperCase(),
          style: const TextStyle(
            fontSize: 25,
            color: AppColors.pink,
            fontWeight: FontWeight.bold,
            letterSpacing: -1.8,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.pink, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 15, left: 15, bottom: 25),
            child: Column(
              children: [
                SmallMascotWidget(
                  message: AppStrings.timeMachineDescription,
                  imagePath: 'assets/images/machine.png',
                ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (Rect bounds) {
                          return AppColors.orangeGradient.createShader(bounds);
                        },
                        child: Text(
                          'Доступные эпохи:'.toUpperCase(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    EraCard(
                      context: context,
                      title: 'Рождение кода (2005-2016)',
                      description:
                          'Основание компании, первые проекты и партнерства',
                      attemptsLeft:
                          _attemptsRemaining['Рождение кода (2005-2016)']!,
                      onTap:
                          () => _navigateToQuiz(
                            context,
                            'Рождение кода (2005-2016)',
                          ),
                    ),
                    EraCard(
                      context: context,
                      title: 'Эпоха прорыва (2017-2019)',
                      description:
                          'Расширение направлений и международное присутствие',
                      attemptsLeft:
                          _attemptsRemaining['Эпоха прорыва (2017-2019)']!,
                      onTap:
                          () => _navigateToQuiz(
                            context,
                            'Эпоха прорыва (2017-2019)',
                          ),
                    ),
                    EraCard(
                      context: context,
                      title: 'Цифровая революция (2020-2023)',
                      description:
                          'Инновационные решения и цифровая трансформация',
                      attemptsLeft:
                          _attemptsRemaining['Цифровая революция (2020-2023)']!,
                      onTap:
                          () => _navigateToQuiz(
                            context,
                            'Цифровая революция (2020-2023)',
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
