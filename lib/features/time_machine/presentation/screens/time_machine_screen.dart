import 'package:flutter/material.dart';
import 'package:neoflex_quest/core/database/database_service.dart';
import 'package:neoflex_quest/core/models/user.dart';
import 'package:neoflex_quest/features/time_machine/presentation/screens/quiz_screen.dart';
import '../../../../shared/widgets/mascot_widget.dart';

class TimeMachineScreen extends StatelessWidget {
  final int userId;
  final VoidCallback onUpdate;

  const TimeMachineScreen({
    required this.userId,
    required this.onUpdate,
    Key? key,
  }) : super(key: key);

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
                        () => _navigateToQuiz(context, 'Рождение кода'),
                  ),
                  _buildEraCard(
                    context,
                    'Эпоха прорыва (2017-2019)',
                    'Расширение направлений и международное присутствие',
                        () => _navigateToQuiz(context, 'Эпоха прорыва'),
                  ),
                  _buildEraCard(
                    context,
                    'Цифровая революция (2020-2023)',
                    'Инновационные решения и цифровая трансформация',
                        () => _navigateToQuiz(context, 'Цифровая революция'),
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
      VoidCallback onTap,
      ) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(description),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onTap,
                  child: Text('Начать'),
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

  void _navigateToQuiz(BuildContext context, String era) async {
    try {
      final user = await _getUserById(userId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            userId: userId,
            era: era,
            user: user,
            onUpdate: onUpdate,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки данных пользователя: ${e.toString()}')),
      );
    }
  }
}