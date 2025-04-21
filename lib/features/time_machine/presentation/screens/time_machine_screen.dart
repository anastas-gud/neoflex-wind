import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/database/database_service.dart';
import 'package:neoflex_quest/core/models/user.dart';
import 'package:neoflex_quest/features/time_machine/presentation/screens/quiz_screen.dart';
import '../../../../shared/widgets/mascot_widget.dart';

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

  @override
  void initState() {
    super.initState();
    _loadAttempts();
  }

  Future<void> _loadAttempts() async {
    final connection = await DatabaseService().getConnection();
    try {
      final results = await connection.query(
        'SELECT era, attempts_used FROM test_attempts WHERE user_id = @userId',
        substitutionValues: {'userId': widget.userId},
      );

      setState(() {
        for (var row in results) {
          final era = row[0] as String;
          final used = row[1] as int;
          final displayEra = _getDisplayEraName(era);
          if (_attemptsRemaining.containsKey(displayEra)) {
            _attemptsRemaining[displayEra] = 3 - used;
          }
        }
      });
    } finally {
      await connection.close();
    }
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
    if (displayEra.startsWith('Цифровая революция')) return 'Цифровая революция';
    return displayEra;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Машина времени')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MascotWidget(
              message: 'Инициирую протокол временнОго перемещения... '
                  'Сканирование архивных данных... '
                  'Обнаружен доступ к модулю "Хронохранилище Neoflex"...\n\n'
                  'Приветствую тебя в блоке "Машина времени". '
                  'Данный сегмент содержит цифровые отпечатки ключевых событий Neoflex. '
                  'Оптимальный метод интеграции в компанию – изучение ее истории. '
                  'Поэтому, юнит, приготовься к прыжку сквозь эпохи!\n\n'
                  'Внимание! Системное предупреждение: Обнаружена ошибка целостности… '
                  'Для активации полного доступа требуется восстановление недостающей информации…\n\n'
                  'Кажется, у нас проблемы, вместо четкой хроники перед нами цифровая головоломка '
                  'с заполнением пропусков. Я выделил 3 временные эпохи, в каждой – принадлежащие '
                  'ей ключевые события, но некоторые варианты... скажем так, альтернативные. '
                  'Помоги собрать пазл, чтобы понять, как мы стали теми, кто мы есть.\n\n'
                  'Рекомендация: для успешного прохождения испытания необходимо выбрать среди '
                  'предоставленных вариантов правдивые факты, подсказки можно найти в соцсетях компании.\n\n'
                  'Ограничение: у вас есть 3 попытки на прохождение каждого теста.\n\n'
                  'Ожидание действий юнита для начала калибровки временных точек…',
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Доступные эпохи:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _buildEraCard(
                    context,
                    'Рождение кода (2005-2016)',
                    'Основание компании, первые проекты и партнерства',
                    _attemptsRemaining['Рождение кода (2005-2016)']!,
                        () => _navigateToQuiz(context, 'Рождение кода (2005-2016)'),
                  ),
                  _buildEraCard(
                    context,
                    'Эпоха прорыва (2017-2019)',
                    'Расширение направлений и международное присутствие',
                    _attemptsRemaining['Эпоха прорыва (2017-2019)']!,
                        () => _navigateToQuiz(context, 'Эпоха прорыва (2017-2019)'),
                  ),
                  _buildEraCard(
                    context,
                    'Цифровая революция (2020-2023)',
                    'Инновационные решения и цифровая трансформация',
                    _attemptsRemaining['Цифровая революция (2020-2023)']!,
                        () => _navigateToQuiz(context, 'Цифровая революция (2020-2023)'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEraCard(
      BuildContext context,
      String title,
      String description,
      int attemptsLeft,
      VoidCallback onTap,
      ) {
    final canAttempt = attemptsLeft > 0;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: canAttempt ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 8),
              Text(description),
              Text(
                'Попыток: $attemptsLeft/3',
                style: TextStyle(
                  color: attemptsLeft > 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: canAttempt ? onTap : null,
                  child: Text(canAttempt ? 'Начать' : 'Попытки исчерпаны'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAttempt ? null : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<User> _getUserById(int userId) async {
    final connection = await DatabaseService().getConnection();
    try {
      final result = await connection.query(
        'SELECT id, username, email, points FROM users WHERE id = @userId',
        substitutionValues: {'userId': userId},
      );
      if (result.isEmpty) throw Exception('Пользователь не найден');
      final row = result.first;
      return User(
        id: row[0] as int,
        username: row[1] as String,
        email: row[2] as String,
        points: row[3] as int,
      );
    } finally {
      await connection.close();
    }
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

    final user = await _getUserById(widget.userId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
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
}